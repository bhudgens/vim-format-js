let s:jsFolder = expand("<sfile>:p:h") . "/../js/"
let s:payloadName = s:jsFolder . "payload.js"
let s:jsName = s:jsFolder . "beautify.js"
"Remembering current position ignoring all blank symbols
function! s:GetNumberOfNonSpaceCharactersFromTheStartOfFile(position)
    let cursorRow = a:position.line
    let cursorColumn = a:position.column
    let lineNumber = 1
    let nonBlankCount = 0
    while lineNumber <= cursorRow
        let lineContent = getline(lineNumber)
        if lineNumber == cursorRow
            let lineContent = strpart(lineContent,0,cursorColumn)
        endif
        let charIndex = 0
        while charIndex < len(lineContent)
            let char = strpart(lineContent,charIndex,1)
            if match(char,'\s') == -1
                let nonBlankCount = nonBlankCount + 1
            endif
            let charIndex = charIndex + 1
        endwhile
        let lineNumber = lineNumber + 1
    endwhile
    return nonBlankCount
endfunction

"Converts number of non blank characters to cursor position (line and column)
function! s:GetCursorPosition(numberOfNonBlankCharactersFromTheStartOfFile)
    "echo a:numberOfNonBlankCharactersFromTheStartOfFile
    let lineNumber = 1
    let nonBlankCount = 0
    while lineNumber <= line('$')
        let lineContent = getline(lineNumber)
        let charIndex = 0
        while charIndex < len(lineContent)
            let char = strpart(lineContent,charIndex,1)
            if match(char,'\s') == -1
                let nonBlankCount = nonBlankCount + 1
            endif
            let charIndex = charIndex + 1
            if nonBlankCount == a:numberOfNonBlankCharactersFromTheStartOfFile 
                "echo 'found position!'
                return {'line': lineNumber,'column': charIndex}
            end
        endwhile
        let lineNumber = lineNumber + 1
    endwhile
    "echo "Oops, nothing found!"
endfunction

"Restoring current position by number of non blank characters
function! s:SetNumberOfNonSpaceCharactersBeforeCursor(mark,numberOfNonBlankCharactersFromTheStartOfFile)
    let location = s:GetCursorPosition(a:numberOfNonBlankCharactersFromTheStartOfFile)
    call setpos(a:mark, [0, location.line, location.column, 0])
endfunction

function! s:GetCursorAndMarksPositions()
    let localMarks = map(range(char2nr('a'), char2nr('z'))," \"'\".nr2char(v:val) ") 
    let marks = ['.'] + localMarks
    let result = {}
    for positionType in marks
        let cursorPositionAsList = getpos(positionType)
        let cursorPosition = {'buffer': cursorPositionAsList[0], 'line': cursorPositionAsList[1], 'column': cursorPositionAsList[2]}
        if cursorPosition.buffer == 0 && cursorPosition.line > 0
            let result[positionType] = cursorPosition
        endif
    endfor
    return result
endfunction

function! s:FormatJs()
    let cursorPositions = s:GetCursorAndMarksPositions()
    call map(cursorPositions, " extend (v:val,{'characters': s:GetNumberOfNonSpaceCharactersFromTheStartOfFile(v:val)}) ")

    let s:optionsName = s:GetOptionsFileName()
    execute "%!js " . s:payloadName . " " . s:jsName . " " . s:optionsName

    for [key,value] in items(cursorPositions)
        call s:SetNumberOfNonSpaceCharactersBeforeCursor(key,value.characters)
    endfor
endfunction
function! s:GetOptionsFileName()
    let s:optionsInCurrentFolder = ".jsbeautify"
    let s:optionsInHomeFolder = "~/.jsbeautify" 
    let s:optionsInPlugin = s:jsFolder . "settings.js" 
    for fileName in [s:optionsInCurrentFolder,s:optionsInHomeFolder,s:optionsInPlugin]
        if filereadable(fileName)
            return fileName
        endif
    endfor
endfunction

command! FormatJs call <SID>FormatJs()
nmap <leader>ff :FormatJs<cr>
