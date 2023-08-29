$source = @"
using System;
using System.Runtime.InteropServices;

public class MyCredentialManager
{
    [DllImport("Advapi32.dll", EntryPoint = "CredWriteW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool CredWrite(ref NativeCredential userCredential, UInt32 flags);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct NativeCredential
    {
        public UInt32 Flags;
        public CRED_TYPE Type;
        public IntPtr TargetName;
        public IntPtr Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public UInt32 CredentialBlobSize;
        public IntPtr CredentialBlob;
        public UInt32 Persist;
        public UInt32 AttributeCount;
        public IntPtr Attributes;
        public IntPtr TargetAlias;
        public IntPtr UserName;
    }

    public enum CRED_TYPE : uint
    {
        GENERIC = 1,
        // ... other credential types
    }

    public static void CreateCredential(string targetName, string userName, string password)
    {
        var cred = new NativeCredential
        {
            Type = CRED_TYPE.GENERIC,
            TargetName = Marshal.StringToCoTaskMemUni(targetName),
            UserName = Marshal.StringToCoTaskMemUni(userName),
            CredentialBlobSize = (UInt32)(password.Length * 2),
            CredentialBlob = Marshal.StringToCoTaskMemUni(password),
            Persist = 2  // CRED_PERSIST_ENTERPRISE
        };

        bool success = CredWrite(ref cred, 0);

        Marshal.FreeCoTaskMem(cred.TargetName);
        Marshal.FreeCoTaskMem(cred.UserName);
        Marshal.FreeCoTaskMem(cred.CredentialBlob);

        if (success)
        {
            Console.WriteLine("Credential created successfully.");
        }
        else
        {
            int lastError = Marshal.GetLastWin32Error();
            Console.WriteLine("Failed to create credential. Last Win32 error: {lastError}");
        }
    }
}
"@

Add-Type -TypeDefinition $source -Language CSharp

$credentialManager = New-Object MyCredentialManager

$credentialManager::CreateCredential("targetname", "username", "password")
