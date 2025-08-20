import argparse
import datetime
import json
import re
import subprocess
import sys

from functools import cmp_to_key
from termcolor import colored

timestamp_format = r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'
utime_secs_format = r'\d+\.\d+'
time_format = f"{timestamp_format} \[\s*{utime_secs_format}]"

timestamp_pattern = re.compile(timestamp_format)
utime_secs_pattern = re.compile(utime_secs_format)
time_pattern = re.compile(time_format)

ansi_escape_pattern = re.compile(r'(\x1b\[[0-9;]*m)')

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


def timestamp_to_datetime(time):
    return datetime.datetime.strptime(time, "%Y-%m-%dT%H:%M:%S")


def compare_time(a, b):
    a_timestamp = timestamp_pattern.search(a)
    b_timestamp = timestamp_pattern.search(b)
    a_utime = utime_secs_pattern.search(a)
    b_utime = utime_secs_pattern.search(b)
    if a_timestamp != None and b_timestamp != None:
        a_datetime = timestamp_to_datetime(a_timestamp.group())
        b_datetime = timestamp_to_datetime(b_timestamp.group())
        if a_datetime != b_datetime:
            if a_datetime < b_datetime:
                return -1
            if a_datetime > b_datetime:
                return 1

    if (a_utime != None and b_utime != None):
        return float(a_utime.group()) - float(b_utime.group())

    return 0;

def parse_grep(lines, hide_log_file, after, before):
    time_to_line = dict()
    times = list()

    reformatted_lines = list()

    longest_file_info = 0;

    for line in lines:
        m = time_pattern.search(line)
        if m != None:
            time = m.group()

            timestamp = timestamp_to_datetime(timestamp_pattern.search(time).group())
            if after != None and timestamp < after:
                continue
            if before != None and timestamp > before:
                continue

            color_seq_match = ansi_escape_pattern.search(line)
            color_seq = color_seq_match.group() if color_seq_match != None else ""
            file_info = line[:m.start()]
            log_message = line[m.end():]
            time_to_line[time] = (color_seq, file_info, log_message)
            times.append(time)

            if len(file_info) > longest_file_info:
                longest_file_info = len(file_info)

    sorted_timestamps = sorted(times, key=cmp_to_key(compare_time))

    for timestamp in sorted_timestamps:
        color_seq, file_info, log_message = time_to_line[timestamp]

        if hide_log_file:
            reformatted_lines.append(f"{color_seq}{timestamp}{log_message}")
        else:
            reformatted_lines.append(f"{color_seq}{timestamp} [{file_info.rjust(longest_file_info)}]{log_message}")

    return reformatted_lines

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
                        action="store_true",
                        help="Don't print source log info to condense output")

    args = parser.parse_args()

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
        lines = parse_grep(output,
                           args.hide_source_log,
                           timestamp_to_datetime(args.after) if args.after != None else None,
                           timestamp_to_datetime(args.before) if args.before != None else None)
        for line in lines:
            for pattern in args.pattern:
                matches = re.finditer(pattern, line)
                for match in matches:
                    line = line[:match.start()] + colored(match.group(), "cyan") + line[match.end():]
            print(line)


    except subprocess.CalledProcessError as e:
        print(e.returncode)
        print(e.output)

