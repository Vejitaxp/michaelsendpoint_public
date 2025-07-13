# Copyright: (c) 2021, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Set-AutoLogon {
    <#
    .SYNOPSIS
    Sets the Windows AutoLogon registry keys

    .DESCRIPTION
    Sets the Windows AutoLogon registry keys and stores the password as an LSA secret.

    .PARAMETER Credential
    The username and password to set to AutoLogon. This account must be valid on the host it is run on.

    .PARAMETER LogonCount
    The number of times to do an automatic logon. Once the count reaches 0 then the automatic logon process is
    disabled.

    .PARAMETER Clear
    Clears the existing AutoLogon settings and removes the stored password secret. This is mutually exclusive with
    -Credential and -LogonCount.

    .EXAMPLE Sets an account to auto logon on reboot.
    $cred = Get-Credential
    Set-AutoLogon -Credential $cred

    .EXAMPLE Clears any AutoLogon settings
    Set-AutoLogon -Clear

    .NOTES
    This must be run as an admin.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='Set')]
    param (
        [Parameter(Mandatory, ParameterSetName='Set')]
        [PSCredential]
        $Credential,

        [Parameter(ParameterSetName='Set')]
        [Int32]
        $LogonCount,

        [Parameter(ParameterSetName='Clear')]
        [Switch]
        $Clear
    )

    end {
        Add-Type -TypeDefinition @'
using Microsoft.Win32.SafeHandles;
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Security;
using System.Text;

namespace AutoLogon
{
    internal class NativeHelpers
    {
        [StructLayout(LayoutKind.Sequential)]
        public class LSA_OBJECT_ATTRIBUTES
        {
            public UInt32 Length = 0;
            public IntPtr RootDirectory = IntPtr.Zero;
            public IntPtr ObjectName = IntPtr.Zero;
            public UInt32 Attributes = 0;
            public IntPtr SecurityDescriptor = IntPtr.Zero;
            public IntPtr SecurityQualityOfService = IntPtr.Zero;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        internal struct LSA_UNICODE_STRING
        {
            public UInt16 Length;
            public UInt16 MaximumLength;
            public IntPtr Buffer;
        }
    }

    internal class NativeMethods
    {
        [DllImport("Advapi32.dll")]
        public static extern UInt32 LsaClose(
            IntPtr ObjectHandle);

        [DllImport("Advapi32.dll")]
        internal static extern Int32 LsaNtStatusToWinError(
            UInt32 Status);

        [DllImport("Advapi32.dll")]
        public static extern UInt32 LsaOpenPolicy(
            IntPtr SystemName,
            NativeHelpers.LSA_OBJECT_ATTRIBUTES ObjectAttributes,
            LsaPolicyAccessMask AccessMask,
            out SafeLsaHandle PolicyHandle);

        [DllImport("Advapi32.dll")]
        public static extern UInt32 LsaStorePrivateData(
            SafeLsaHandle PolicyHandle,
            ref NativeHelpers.LSA_UNICODE_STRING KeyName,
            ref NativeHelpers.LSA_UNICODE_STRING PrivateData);
    }

    internal class SafeStringBuffer : SafeBuffer
    {
        internal SafeStringBuffer() : base(true) { }
        internal SafeStringBuffer(String s) : base(true)
        {
            if (s == null)
                base.SetHandle(IntPtr.Zero);
            else
            {
                byte[] stringBytes = Encoding.Unicode.GetBytes(s);
                base.SetHandle(Marshal.AllocHGlobal(stringBytes.Length));
                Marshal.Copy(stringBytes, 0, this.DangerousGetHandle(), stringBytes.Length);
            }
        }

        protected override bool ReleaseHandle()
        {
            Marshal.FreeHGlobal(handle);
            return true;
        }
    }

    internal class SafeSecureBuffer : SafeBuffer
    {
        internal SafeSecureBuffer() : base(true) { }
        internal SafeSecureBuffer(SecureString s) : base(true)
        {
            if (s == null)
                base.SetHandle(IntPtr.Zero);
            else
                base.SetHandle(Marshal.SecureStringToGlobalAllocUnicode(s));
        }

        protected override bool ReleaseHandle()
        {
            Marshal.ZeroFreeGlobalAllocUnicode(handle);
            return true;
        }
    }

    public class SafeLsaHandle : SafeHandleZeroOrMinusOneIsInvalid
    {
        internal SafeLsaHandle() : base(true) { }

        protected override bool ReleaseHandle()
        {
            return NativeMethods.LsaClose(handle) == 0;
        }
    }

    [Flags]
    public enum LsaPolicyAccessMask : uint
    {
        ViewLocalInformation = 0x00000001,
        ViewAuditInformation = 0x00000002,
        GetPrivateInformation = 0x00000004,
        TrustAdmin = 0x00000008,
        CreateAccount = 0x00000010,
        CreateSecret = 0x00000020,
        CreatePrivilege = 0x00000040,
        SetDefaultQuotaLimits = 0x00000080,
        SetAuditRequirements = 0x00000100,
        AuditLogAdmin = 0x00000200,
        ServerAdmin = 0x00000400,
        LookupNames = 0x00000800,
        Read = 0x00020006,
        Write = 0x000207F8,
        Execute = 0x00020801,
        AllAccess = 0x000F0FFF,
    }

    public class LsaUtil
    {
        public static SafeLsaHandle OpenPolicy(LsaPolicyAccessMask access)
        {
            NativeHelpers.LSA_OBJECT_ATTRIBUTES oa = new NativeHelpers.LSA_OBJECT_ATTRIBUTES();
            SafeLsaHandle lsaHandle;
            UInt32 res = NativeMethods.LsaOpenPolicy(IntPtr.Zero, oa, access, out lsaHandle);
            if (res != 0)
                throw new Win32Exception(NativeMethods.LsaNtStatusToWinError(res));

            return lsaHandle;
        }

        public static void StorePrivateData(string key, SecureString data)
        {
            using (var handle = OpenPolicy(LsaPolicyAccessMask.CreateSecret))
            using (var keyBuffer = new SafeStringBuffer(key))
            using (var dataBuffer = new SafeSecureBuffer(data))
            {
                var keyString = new NativeHelpers.LSA_UNICODE_STRING()
                {
                    Length = (UInt16)(key.Length * 2),
                    MaximumLength = (UInt16)(key.Length * 2),
                    Buffer = keyBuffer.DangerousGetHandle(),
                };

                UInt16 dataLength = (UInt16)(data == null ? 0 : data.Length * 2);
                var dataString = new NativeHelpers.LSA_UNICODE_STRING()
                {
                    Length = dataLength,
                    MaximumLength = dataLength,
                    Buffer = dataBuffer.DangerousGetHandle(),
                };

                UInt32 res = NativeMethods.LsaStorePrivateData(handle, ref keyString, ref dataString);
                if (res != 0)
                {
                    // When clearing the private data with null it may return this error which we can ignore.
                    if (data == null && res == 0xC0000034)  // STATUS_OBJECT_NAME_NOT_FOUND
                        return;

                    throw new Win32Exception(NativeMethods.LsaNtStatusToWinError(res));
                }
            }
        }
    }
}
'@

        $autoLogonRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
        $propParams = @{
            LiteralPath = $autoLogonRegPath
            Force = $true
        }

        # Whether we are clearing or setting the password in LSA we don't want this prop to exist at all.
        if ('DefaultPassword' -in (Get-Item -LiteralPath $autoLogonRegPath).Property) {
            if ($PSCmdlet.ShouldProcess("$autoLogonRegPath DefaultPassword", "Remove")) {
                Remove-ItemProperty -Name 'DefaultPassword' @propParams
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Set') {
            # Translating from NTAccount -> SID -> NTAccount gives us the Netlogon form
            try {
                $username = [Security.Principal.NTAccount]::new($Credential.UserName).Translate(
                    [Security.Principal.SecurityIdentifier]).Translate([Security.Principal.NTAccount])
            }
            catch [Security.Principal.IdentityNotMappedException] {
                $err = [Management.Automation.ErrorRecord]::new(
                    $_.Exception,
                    "AutoLogon.IdentityNotMappedException",
                    'InvalidArgument',
                    $null
                )
                $err.ErrorDetails = [Management.Automation.ErrorDetails]::new(
                    "Credential username '$($Credential.UserName)' is not a valid Windows identity"
                )

                $PSCmdlet.WriteError($err)
                return
            }
            $domain, $username = $username -split '\\', 2

            if ($PSCmdlet.ShouldProcess("$autoLogonRegPath AutoAdminLogon", "Enable")) {
                New-ItemProperty -Name 'AutoAdminLogon' -Value 1 -PropertyType DWord @propParams | Out-Null
            }

            $propMap = @{
                DefaultUserName = $username
                DefaultDomainName = $domain
            }
            if ($PSBoundParameters.ContainsKey('LogonCount')) {
                $propMap.AutoLogonCount = $LogonCount
            }

            foreach ($prop in $propMap.GetEnumerator()) {
                $k = $prop.Key
                $v = $prop.Value
                if ($PSCmdlet.ShouldProcess("$autoLogonRegPath $k", "Set $v")) {
                    New-ItemProperty -Name $k -Value $v @propParams | Out-Null
                }
            }

            $password = $Credential.Password
        }
        else {
            if ($PSCmdlet.ShouldProcess("$autoLogonRegPath AutoAdminLogon", "Disable")) {
                New-ItemProperty -Name 'AutoAdminLogon' -Value 0 -PropertyType DWord @propParams | Out-Null
            }

            $logonDetails = Get-ItemProperty -LiteralPath $autoLogonRegPath
            foreach ($key in 'DefaultUserName', 'DefaultDomainName', 'AutoLogonCount') {
                if ($key -in $logonDetails.PSObject.Properties.Name) {
                    if ($PSCmdlet.ShouldProcess("$autoLogonRegPath $key", "Remove")) {
                        Remove-ItemProperty -Name $key @propParams
                    }
                }
            }

            $password = $null
        }

        try {
            if ($PSCmdlet.ShouldProcess("Lsa", "Set password")) {
                [AutoLogon.LsaUtil]::StorePrivateData('DefaultPassword', $password)

                # LSA secrets store the previous value, if removing it we want to run this one more time
                if ($null -eq $password) {
                    [AutoLogon.LsaUtil]::StorePrivateData('DefaultPassword', $password)
                }
            }
        }
        catch [ComponentModel.Win32Exception] {
            $err = [Management.Automation.ErrorRecord]::new(
                $_.Exception,
                "AutoLogon.Win32Exception",
                'NotSpecified',
                $null
            )

            $msg = 'Failed to set LSA DefaultPassword ({0}, Win32ErrorCode {1} - 0x{1:X8})' -f @(
                $_.Exception.Message, $_.Exception.NativeErrorCode)
            $err.ErrorDetails = [Management.Automation.ErrorDetails]::new($msg)

            $PSCmdlet.WriteError($err)
            return
        }
    }
}

$user = "AzureAD\test@michaelsendpoint.com"
$plainPassword = "i2EemEgXkDznCN"
$securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($user, $securePassword)
Set-AutoLogon -Credential $cred