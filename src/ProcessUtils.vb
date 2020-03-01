Option Strict On
Option Explicit On

Imports System.ComponentModel
Imports System.Runtime.InteropServices

Public Class ProcessUtils

    Private Class Handler
        Private _outputDataReceived As Action(Of String)
        Private _errorDataReceived As Action(Of String)

        Sub New(OutputDataReceived As Action(Of String),
                ErrorDataReceived As Action(Of String))
            _outputDataReceived = OutputDataReceived
            _errorDataReceived = ErrorDataReceived
        End Sub

        Sub OutputDataReceived(sender As Object, e As DataReceivedEventArgs)
            _outputDataReceived(e.Data)
        End Sub

        Sub ErrorDataReceived(sender As Object, e As DataReceivedEventArgs)
            _errorDataReceived(e.Data)
        End Sub
    End Class

    Shared Function Run(
            FileName As String,
            CommandLineArguments As IEnumerable(Of String),
            Optional TimeoutMilliseconds As Integer? = Nothing,
            Optional OutputDataReceived As Action(Of String) = Nothing,
            Optional ErrorDataReceived As Action(Of String) = Nothing,
            Optional WorkingDirectory As String = Nothing,
            Optional EnvironmentVariables As IEnumerable(Of Tuple(Of String, String)) = Nothing
        ) As Integer
        Using proc = Start(
                FileName:=FileName,
                CommandLineArguments:=CommandLineArguments,
                OutputDataReceived:=OutputDataReceived,
                ErrorDataReceived:=ErrorDataReceived,
                WorkingDirectory:=WorkingDirectory,
                EnvironmentVariables:=EnvironmentVariables
            )
            If TimeoutMilliseconds.HasValue Then
                proc.WaitForExit(TimeoutMilliseconds.Value)
            Else
                proc.WaitForExit()
            End If

            Return proc.ExitCode
        End Using
    End Function

    Shared Function Start(
            FileName As String,
            CommandLineArguments As IEnumerable(Of String),
            Optional OutputDataReceived As Action(Of String) = Nothing,
            Optional ErrorDataReceived As Action(Of String) = Nothing,
            Optional WorkingDirectory As String = Nothing,
            Optional EnvironmentVariables As IEnumerable(Of Tuple(Of String, String)) = Nothing
        ) As Process
        Dim proc As New Process()
        Try
            proc.StartInfo.FileName = FileName

            Dim args = String.Join(" ", CommandLineArguments.Select(
                                       Function(x)
                                           Return """" & Text.RegularExpressions.Regex.Replace(x, "(\\+)$", "$1$1") & """"
                                       End Function))
            proc.StartInfo.Arguments = args
            proc.StartInfo.UseShellExecute = False
            proc.StartInfo.WindowStyle = ProcessWindowStyle.Hidden
            If EnvironmentVariables IsNot Nothing Then
                For Each envVar In EnvironmentVariables
                    proc.StartInfo.EnvironmentVariables(envVar.Item1) = envVar.Item2
                Next
            End If

            If WorkingDirectory IsNot Nothing Then proc.StartInfo.WorkingDirectory = WorkingDirectory

            Dim h As New Handler(OutputDataReceived, ErrorDataReceived)
            If OutputDataReceived IsNot Nothing Then
                proc.StartInfo.RedirectStandardOutput = True
                AddHandler proc.OutputDataReceived, AddressOf h.OutputDataReceived
            End If
            If ErrorDataReceived IsNot Nothing Then
                proc.StartInfo.RedirectStandardError = True
                AddHandler proc.ErrorDataReceived, AddressOf h.ErrorDataReceived
            End If

            If Not proc.Start Then
                Throw New Exception("Couldnt start")
            End If
            proc.BeginOutputReadLine()
            proc.BeginErrorReadLine()
        Catch ex As Exception
            proc.Dispose()
            Throw
        End Try

        Return proc
    End Function

    Shared Sub AddChildProcess(Process As Process)
        ChildProcessTracker.AddProcess(Process)
    End Sub

    ''' <summary>
    ''' Allows processes to be automatically killed if this parent process unexpectedly quits.
    ''' This feature requires Windows 8 or greater. On Windows 7, nothing is done.</summary>
    ''' <remarks>References:
    '''  http://stackoverflow.com/a/4657392/386091
    '''  http://stackoverflow.com/a/9164742/386091 </remarks>
    Private Class ChildProcessTracker

        ''' <summary>
        ''' Add the process to be tracked. If our current process is killed, the child processes
        ''' that we are tracking will be automatically killed, too. If the child process terminates
        ''' first, that's fine, too.</summary>
        ''' <param name="process"></param>
        Public Shared Sub AddProcess(ByVal process As Process)
            If (s_jobHandle <> IntPtr.Zero) Then
                Dim success As Boolean = ChildProcessTracker.AssignProcessToJobObject(s_jobHandle, process.Handle)
                If Not success Then
                    Throw New Win32Exception
                End If
            End If
        End Sub

        Shared Sub New()
            ' This feature requires Windows 8 or later. To support Windows 7 requires
            '  registry settings to be added if you are using Visual Studio plus an
            '  app.manifest change.
            '  http://stackoverflow.com/a/4232259/386091
            '  http://stackoverflow.com/a/9507862/386091
            'If (Environment.OSVersion.Version < New Version(6, 2)) Then
            '    Return
            'End If

            ' The job name is optional (and can be null) but it helps with diagnostics.
            '  If it's not null, it has to be unique. Use SysInternals' Handle command-line
            '  utility: handle -a ChildProcessTracker
            Dim jobName As String = ("ChildProcessTracker" & Process.GetCurrentProcess.Id)
            s_jobHandle = ChildProcessTracker.CreateJobObject(IntPtr.Zero, jobName)
            Dim info = New JOBOBJECT_BASIC_LIMIT_INFORMATION
            ' This is the key flag. When our process is killed, Windows will automatically
            '  close the job handle, and when that happens, we want the child processes to
            '  be killed, too.
            info.LimitFlags = JOBOBJECTLIMIT.JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
            Dim extendedInfo = New JOBOBJECT_EXTENDED_LIMIT_INFORMATION
            extendedInfo.BasicLimitInformation = info
            Dim length As Integer = Marshal.SizeOf(GetType(JOBOBJECT_EXTENDED_LIMIT_INFORMATION))
            Dim extendedInfoPtr As IntPtr = Marshal.AllocHGlobal(length)
            Try
                Marshal.StructureToPtr(extendedInfo, extendedInfoPtr, False)
                If Not ChildProcessTracker.SetInformationJobObject(
                    s_jobHandle,
                    JobObjectInfoType.ExtendedLimitInformation,
                    extendedInfoPtr,
                    CType(length, UInteger)) Then
                    Throw New Win32Exception
                End If

            Finally
                Marshal.FreeHGlobal(extendedInfoPtr)
            End Try

        End Sub

        'Private Declare Function CreateJobObject Lib "kernel32.dll" (
        '    ByVal lpJobAttributes As IntPtr,
        '    ByVal name As String
        ') As IntPtr

        <DllImport("kernel32.dll", CharSet:=CharSet.Unicode)>
        Private Shared Function CreateJobObject(lpJobAttributes As IntPtr, lpName As String) As IntPtr
        End Function


        Private Declare Function SetInformationJobObject Lib "kernel32.dll" (
            ByVal job As IntPtr,
            ByVal infoType As JobObjectInfoType,
            ByVal lpJobObjectInfo As IntPtr,
            ByVal cbJobObjectInfoLength As UInteger
        ) As Boolean

        Private Declare Function AssignProcessToJobObject Lib "kernel32.dll" (
            ByVal job As IntPtr,
            ByVal process As IntPtr
        ) As Boolean

        ' Windows will automatically close any open job handles when our process terminates.
        '  This can be verified by using SysInternals' Handle utility. When the job handle
        '  is closed, the child processes will be killed.
        Private Shared s_jobHandle As IntPtr
    End Class

    Private Enum JobObjectInfoType

        AssociateCompletionPortInformation = 7

        BasicLimitInformation = 2

        BasicUIRestrictions = 4

        EndOfJobTimeInformation = 6

        ExtendedLimitInformation = 9

        SecurityLimitInformation = 5

        GroupInformation = 11
    End Enum

    <StructLayout(LayoutKind.Sequential)>
    Private Structure JOBOBJECT_BASIC_LIMIT_INFORMATION

        Public PerProcessUserTimeLimit As Int64

        Public PerJobUserTimeLimit As Int64

        Public LimitFlags As JOBOBJECTLIMIT

        Public MinimumWorkingSetSize As UIntPtr

        Public MaximumWorkingSetSize As UIntPtr

        Public ActiveProcessLimit As UInt32

        Public Affinity As Int64

        Public PriorityClass As UInt32

        Public SchedulingClass As UInt32
    End Structure

    <Flags()>
    Private Enum JOBOBJECTLIMIT As UInteger

        JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 8192
    End Enum

    <StructLayout(LayoutKind.Sequential)>
    Private Structure IO_COUNTERS

        Public ReadOperationCount As UInt64

        Public WriteOperationCount As UInt64

        Public OtherOperationCount As UInt64

        Public ReadTransferCount As UInt64

        Public WriteTransferCount As UInt64

        Public OtherTransferCount As UInt64
    End Structure

    <StructLayout(LayoutKind.Sequential)>
    Private Structure JOBOBJECT_EXTENDED_LIMIT_INFORMATION

        Public BasicLimitInformation As JOBOBJECT_BASIC_LIMIT_INFORMATION

        Public IoInfo As IO_COUNTERS

        Public ProcessMemoryLimit As UIntPtr

        Public JobMemoryLimit As UIntPtr

        Public PeakProcessMemoryUsed As UIntPtr

        Public PeakJobMemoryUsed As UIntPtr
    End Structure
End Class
