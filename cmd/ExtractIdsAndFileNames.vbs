' *** Author: T. Wittrock, Kiel ***

Option Explicit

Dim objFileSystem, inputFile, outputFile, strInputFileName, strOutputFileName, bIdsOnly, bNoIds

Private Function IsTextFile(objFS, strFileName)
  IsTextFile = (objFS.FileExists(strFileName)) And ( (LCase(objFS.GetExtensionName(strFileName)) = "txt") Or (LCase(objFS.GetExtensionName(strFileName)) = "csv") )
End Function

Private Function ExtractId(strURL)
  ExtractId = Left(strURL, InStr(strURL, ",") - 1)
End Function

Private Function ExtractFileName(strURL)
  ExtractFileName = Right(strURL, Len(strURL) - InStrRev(strURL, "/"))
End Function

Private Function ExtractIdAndFileName(strURL)
  ExtractIdAndFileName = ExtractId(strURL) & "," & ExtractFileName(strURL)
End Function

Set objFileSystem = CreateObject("Scripting.FileSystemObject")
If WScript.Arguments.Count < 2 Then
  WScript.Echo("ERROR: Missing argument.")
  WScript.Echo("Usage: " & WScript.ScriptName & " <Input file> <Output file>")
  WScript.Quit(1)
End If
strInputFileName = WScript.Arguments(0)
If Not IsTextFile(objFileSystem, strInputFileName) Then
  WScript.Echo("ERROR: Invalid argument '" & strInputFileName & "'")
  WScript.Echo("Usage: " & WScript.ScriptName & " <Input file> <Output file>")
  WScript.Quit(1)
End If
strOutputFileName = WScript.Arguments(1)
If WScript.Arguments.Count > 2 Then
  bIdsOnly = LCase(WScript.Arguments(2)) = "/idsonly"
  bNoIds = LCase(WScript.Arguments(2)) = "/noids"
Else
  bIdsOnly = False
  bNoIds = False
End If

Set inputFile = objFileSystem.OpenTextFile(strInputFileName, 1)
Set outputFile = objFileSystem.CreateTextFile(strOutputFileName, True)
Do While Not inputFile.AtEndOfStream
  If bIdsOnly Then
    outputFile.WriteLine(ExtractId(inputFile.ReadLine()))
  Else
    If bNoIds Then
      outputFile.WriteLine(ExtractFileName(inputFile.ReadLine()))
    Else
      outputFile.WriteLine(ExtractIdAndFileName(inputFile.ReadLine()))
    End If
  End If
Loop
inputFile.Close()
outputFile.Close()
WScript.Quit(0)