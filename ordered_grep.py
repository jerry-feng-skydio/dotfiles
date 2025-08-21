import argparse
import datetime
import json
import re
import subprocess
import sys

from functools import cmp_to_key
from termcolor import colored

timestamp_format = r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'
clock_time_format = r'\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}'
utime_secs_format = r'\d+\.\d+'
time_format = f"{timestamp_format} \[\s*{utime_secs_format}]"

set_system_clock_format = f'uclock from file={clock_time_format}'
runmode_service_start_time_format = f'runmode_service at {clock_time_format}'

timestamp_pattern = re.compile(timestamp_format)
clock_time_pattern = re.compile(clock_time_format)
utime_secs_pattern = re.compile(utime_secs_format)
runmode_service_start_time_pattern = re.compile(runmode_service_start_time_format)
set_system_clock_pattern = re.compile(set_system_clock_format)
time_pattern = re.compile(time_format)

ansi_escape_pattern = re.compile(r'(\x1b\[[0-9;]*m)')

time_format = "%Y-%m-%dT%H:%M:%S"

HIDE_SOURCE = False
LONGEST_FILE_INFO = 0

colors = [
    "red",
    "blue",
    "magenta",
    "cyan",
    "light_red",
    "light_green",
    "light_yellow",
    "light_blue",
    "light_magenta",
    "light_cyan",
]

class Timing:
    def __init__(self, time, utime):
        self.time = time
        self.utime = utime

    def __lt__(self, other):
        if not isinstance(other, Timing):
            return NotImplemented
        if self.time != other.time:
            return self.time < other.time
        else:
            return self.utime < other.utime

class LogMessage:
    def __init__(self, timing, log_file, message, color):
        self.timing = timing
        self.log_file = log_file
        self.message = message
        self.color = color

    def __lt__(self, other):
        if not isinstance(other, LogMessage):
            return NotImplemented
        return self.timing < other.timing


    def __str__(self):
        timestamp = ""
        utime = ""

        if self.timing != None:
            timestamp = "[" + self.timing.time.strftime(time_format) + "] "
            utime = (
                f"[{self.timing.utime:15.6f}] "
                if self.timing.utime >= 0
                else "[" + ("-" * 15) + "] "
            )

        global HIDE_SOURCE
        log_file = (
            f"[{self.log_file.rjust(LONGEST_FILE_INFO)}] "
            if not HIDE_SOURCE
            else ""
        )
        return f"{self.color}{log_file}{utime}{timestamp}{self.message}"

def timestamp_to_datetime(time):
    return datetime.datetime.strptime(time, time_format)

def set_clock_timestamp_to_datetime(time):
    return datetime.datetime.strptime(time, "%Y-%m-%d %H:%M:%S")

def systemd_timestamp_to_datetime(time):
    #  Aug 15 15:04:58
    new_time = datetime.datetime.strptime(time, "%b %d %H:%M:%S")
    new_time.replace(datetime.datetime.now().year)
    return new_time

def extract_log_file(line):
    idx = line.find(":")
    if idx != -1:
        log_file = line[:idx]
        text = line[idx+1:]
        return log_file, text

    return "", line

def extract_nominal_timestamp(line):
    m = time_pattern.search(line)
    if m != None:
        time = m.group()
        datetime = timestamp_to_datetime(timestamp_pattern.search(time).group())
        utime = float(utime_secs_pattern.search(time).group())
        log_message = line[m.end():].lstrip()
        return Timing(datetime, utime), log_message

    return None, line

def extract_runmode_start_timestamp(line):
    m = runmode_service_start_time_pattern.search(line)
    if m != None:
        time = m.group()
        datetime = set_clock_timestamp_to_datetime(clock_time_pattern.search(time).group())
        utime = -9999999
        return Timing(datetime, utime), line

    return None, line

def extract_uclock_set_timestamp(line):
    m = set_system_clock_pattern.search(line)
    if m != None:
        time = m.group()
        datetime = set_clock_timestamp_to_datetime(clock_time_pattern.search(time).group())
        wrong_timing, log_message = extract_nominal_timestamp(line)
        return Timing(datetime, wrong_timing.utime), log_message

    return None, line

def extract_systemd_timestamp(line):
    #  Aug 15 15:04:58
    systemd_timestamp_pattern = re.compile(r"[a-zA-Z]{3} \d{2} \d{2}:\d{2}:\d{2}")
    m = systemd_timestamp_pattern.search(line)
    if m != None:
        time = m.group()
        datetime = systemd_timestamp_to_datetime(time)
        return Timing(datetime, 0), line[m.end():].lstrip()

    return None, line

def extract_timing_info(line):
    timing, log_message = extract_runmode_start_timestamp(line)
    if timing == None:
        timing, log_message = extract_uclock_set_timestamp(line)
    if timing == None:
        timing, log_message = extract_systemd_timestamp(line)

    if timing == None:
        timing, log_message = extract_nominal_timestamp(line)

    return timing, log_message

def extract_first_color_sequence(line):
    color_seq_match = ansi_escape_pattern.search(line)
    color_seq = color_seq_match.group() if color_seq_match != None else ""
    return color_seq

def parse_grep(lines, hide_log_file, after, before):
    messages = list()
    untimestamped_lines = list()

    for line in lines:
        log_file, text = extract_log_file(line)
        timing, message = extract_timing_info(text)
        if timing == None:
            untimestamped_lines.append(line)
        elif after != None and timing.time < after:
            continue
        elif before != None and timing.time > before:
            continue
        else:
            color = extract_first_color_sequence(text)
            messages.append(LogMessage(timing, log_file, message, color))
            global LONGEST_FILE_INFO
            if len(log_file) > LONGEST_FILE_INFO:
                LONGEST_FILE_INFO = len(log_file)

    return sorted(messages), untimestamped_lines

def highlight_search_terms(line, color, patterns):
    for pattern in patterns:
        matches = re.finditer(pattern, line)
        matches_reversed = list()
        for match in matches:
            matches_reversed.insert(0, match)

        for match in matches_reversed:
            line = line[:match.start()] + colored(match.group(), "cyan") + color + line[match.end():]

    return line


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory",
                        "-d",
                        type=str,
                        help="Directory to run search in. Uses cwd if not provided",
                        default=".")
    parser.add_argument("--after",
                        "-a",
                        type=str,
                        default=None,
                        help="Filter for messages after given timestamp. Timestamp string is expected to be in YY-MM-DDTHH:MM:SS format")
    parser.add_argument("--before",
                        "-b",
                        type=str,
                        default=None,
                        help="Filter for messages before given timestamp. Timestamp string is expected to be in YY-MM-DDTHH:MM:SS format")
    parser.add_argument("--pattern",
                        "-p",
                        action="extend",
                        type=str,
                        nargs='+',
                        default=None,
                        help="String patterns to search for")
    parser.add_argument("--regex",
                        "-r",
                        action="store_true",
                        default=True,
                        help="Use extended regex")
    parser.add_argument("--hide_source_log",
                        "-x",
                        default=False,
                        action="store_true",
                        help="Don't print source log info to condense output")

    args = parser.parse_args()

    HIDE_SOURCE = args.hide_source_log

    cmd = [
        "grep",
        "-r",
    ]
    if args.regex:
        cmd.append("-E")

    regexes = list()

    if args.pattern != None:
        for pattern in args.pattern:
            regexes.append(re.compile(pattern))
            if args.regex:
                pattern = pattern.replace(r"\d", "[[:digit:]]")
                pattern = pattern.replace(r"\D", "[^[:digit:]]")
                pattern = pattern.replace(r"\w", "[[:alnum:]]")
                pattern = pattern.replace(r"\W", "[^[:alnum:]]")
                pattern = pattern.replace(r"\s", "[[:space:]]")
            cmd.append("-e")
            cmd.append(pattern)

    cmd.append(".")

    print(cmd)
    try:
        output = subprocess.check_output(cmd).decode('utf-8').split("\n")
        messages, unordered = parse_grep(
            output,
            args.hide_source_log,
            timestamp_to_datetime(args.after) if args.after != None else None,
            timestamp_to_datetime(args.before) if args.before != None else None
        )

        for message in messages:
            line = highlight_search_terms(str(message), message.color, args.pattern)
            print(line)

        for message in unordered:
            line = highlight_search_terms(message, "", args.pattern)
            print(line)


    except subprocess.CalledProcessError as e:
        print(e.returncode)
        print(e.output)

