" Vim syntax file
" Language:   LCM (Lightweight Communications and Marshalling)
" Reference:  https://lcm-proj.github.io/lcm/
" Filenames:  *.lcm

if exists("b:current_syntax")
  finish
endif

" Comments
syn keyword lcmTodo        contained TODO FIXME XXX NOTE HACK BUG
syn match   lcmLineComment "\/\/.*$" contains=lcmTodo,@Spell
syn region  lcmBlockComment start="/\*" end="\*/" contains=lcmTodo,@Spell

" Preprocessor / codegen directives (Skydio extensions)
syn match   lcmDirective   "^#\(protobuf\|djinni\|channel\)\>"
syn region  lcmDirective   start="^#protobuf{" end="}"

" Package declaration
syn keyword lcmPackage     package nextgroup=lcmPackageName skipwhite
syn match   lcmPackageName "\h\w*" contained

" Top-level keywords
syn keyword lcmKeyword     struct enum

" Field-level keywords
syn keyword lcmKeyword     const

" Primitive types
syn keyword lcmType        int8_t int16_t int32_t int64_t
syn keyword lcmType        uint8_t uint16_t uint32_t uint64_t
syn keyword lcmType        float double string boolean byte

" Qualified type references (e.g. eigen_lcm.Quaterniond, body.trans_t)
syn match   lcmQualType    "\h\w*\.\h\w*"

" Constants and enum values
syn match   lcmConstant    "\<[A-Z][A-Z0-9_]*\>"

" Numbers
syn match   lcmNumber      "\<\d\+\>"
syn match   lcmNumber      "\<0[xX][0-9a-fA-F]\+\>"
syn match   lcmFloat       "\<\d\+\.\d*\([eE][-+]\?\d\+\)\?\>"
syn match   lcmFloat       "\<\.\d\+\([eE][-+]\?\d\+\)\?\>"
syn match   lcmFloat       "\<\d\+[eE][-+]\?\d\+\>"

" Negative numbers (for default values like -273.15)
syn match   lcmNumber      "-\d\+\>"
syn match   lcmFloat       "-\d\+\.\d*\([eE][-+]\?\d\+\)\?\>"

" Boolean literals
syn keyword lcmBoolean     true false

" Strings (rarely used but valid)
syn region  lcmString      start='"' skip='\\"' end='"'

" Field assignment (protobuf-style field numbers: = 1, = 2, etc.)
syn match   lcmFieldNumber "=\s*\d\+" contains=lcmNumber

" Array brackets
syn region  lcmArray       matchgroup=lcmBracket start="\[" end="\]" contains=lcmNumber,lcmConstant

" Highlight links
hi def link lcmLineComment  Comment
hi def link lcmBlockComment Comment
hi def link lcmTodo         Todo
hi def link lcmDirective    PreProc
hi def link lcmPackage      Statement
hi def link lcmPackageName  Identifier
hi def link lcmKeyword      Keyword
hi def link lcmType         Type
hi def link lcmQualType     Type
hi def link lcmConstant     Constant
hi def link lcmNumber       Number
hi def link lcmFloat        Float
hi def link lcmBoolean      Boolean
hi def link lcmString       String
hi def link lcmBracket      Delimiter
hi def link lcmFieldNumber  Special

let b:current_syntax = "lcm"
