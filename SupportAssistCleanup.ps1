<#
.Synopsis
v4.5.0.0 11-Sep-2024
.Description
This script Uninstalls and Cleans up Dell SupportAssist for PCs if installed on the box.
.FileName
SupportAssistUninstall_Cleanup.ps1
#>
<#
Return Codes: 
	Exit 0 : Uninstall/Cleanup Successful.
	Exit 1 : Uninstall/Cleanup Successful with reboot required.
	Exit X : Uninstall/Cleanup Failed.
EventID :
	Information : 0
	Error : 11725
#>

$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

# Define the name of the application
$AppName = "Dell SupportAssist"
New-EventLog -LogName Application -Source "SupportAssistUninstall_Cleanup" -ErrorAction SilentlyContinue

# Define the registry path for uninstall information
$UninstallPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

# Function to find the product code for the given application
function Find-ProductCode {
    param (
        [string]$appName
    )

    # Get a list of all subkeys in the Uninstall registry path
    $uninstallKeys = Get-ChildItem $UninstallPath

    foreach ($key in $uninstallKeys) {
        $appInfo = Get-ItemProperty $key.PSPath
		
        # Check if DisplayName matches the application name
        if ($appInfo.DisplayName -eq $appName) 
		{
			#Write-Host "Dell SupportAssist Application found"
			$SupportAssistType = Get-ItemProperty -Path 'HKLM:\SOFTWARE\DELL\SupportAssistAgent' | Select-Object -ExpandProperty 'Type'
			if($SupportAssistType = "Consumer")
			{
				#Write-Host "Consumer found"
				# Return the ProductCode
				return $appInfo.PSChildName	
			}
        }
    }

    # If the application is not found, return $null
    return $null
}

# Function to uninstall the application using msiexec and log exit codes
function Uninstall-Application {
    param (
        [string]$productCode
    )
	
	#Write-Host $productCode
	if ($productCode -eq "")	
	{
        Write-EventLog -LogName "Application" -Source "SupportAssistUninstall_Cleanup" -EventID 0 -EntryType Information -Message "SupportAssist for Home PCs not found. SupportAssistUninstall_Cleanup script execution was completed successfully." -Category 0
		[System.Environment]::Exit(0)
    }

    # Define the parameters for silent uninstallation
    $msiParams = "/x $productCode /qn /log uninstall.log"

    # Uninstall the application using msiexec
    $result = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiParams -Wait -PassThru

    # Log exit code and description
    $logEntry = "Exit Code: $($result.ExitCode) - Description: $($result.ExitCodeMessage)"
    Add-Content -Path "uninstall.log" -Value $logEntry

    switch ($result.ExitCode) {
        0 {
            #Write-Host "Uninstallation successful."
			Write-EventLog -LogName "Application" -Source "SupportAssistUninstall_Cleanup" -EventID 0 -EntryType Information -Message "SupportAssist for Home PCs uninstallation successful. SupportAssistUninstall_Cleanup script execution was completed successfully." -Category 0
			[System.Environment]::Exit(0)
        }
        1641 {
            #Write-Host "Uninstallation successful, but a reboot is required."
			Write-EventLog -LogName "Application" -Source "SupportAssistUninstall_Cleanup" -EventID 0 -EntryType Information -Message "Restart Required.  SupportAssist for Home PCs uninstallation successful. SupportAssistUninstall_Cleanup script execution Completed." -Category 0
			[System.Environment]::Exit(1)
        }
		3010 {
            #Write-Host "Uninstallation successful, but a reboot is required."
			Write-EventLog -LogName "Application" -Source "SupportAssistUninstall_Cleanup" -EventID 0 -EntryType Information -Message "Restart Required. SupportAssistUninstall_Cleanup script execution completed." -Category 0
			[System.Environment]::Exit(1)
        }
        default {
            #Write-Host "Uninstallation failed. Exit Code: $($result.ExitCode)"
			Write-EventLog -LogName "Application" -Source "SupportAssistUninstall_Cleanup" -EventID 0 -EntryType Error -Message "SupportAssistUninstall_Cleanup script failed to remove SupportAssist for Home PCs.
			" -Category 0
			[System.Environment]::Exit(2)
        }
    }
}

# Main Entry point
try {
    # Find the product code for the application
    $productCode = Find-ProductCode -appName $AppName

    # Uninstall the application using the product code
    Uninstall-Application -productCode $productCode
} catch {
    #Write-Host "An error occurred: $_"
	Write-EventLog -LogName "Application" -Source "SupportAssistUninstall_Cleanup" -EventID 0 -EntryType Information -Message "SupportAssistUninstall_Cleanup script failed with error: $_" -Category 0
	[System.Environment]::Exit(2)
}

# SIG # Begin signature block
# MIIrPgYJKoZIhvcNAQcCoIIrLzCCKysCAQExDzANBglghkgBZQMEAgMFADCBmwYK
# KwYBBAGCNwIBBKCBjDCBiTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63
# JNLGKX7zUQIBAAIBAAIBAAIBAAIBADBRMA0GCWCGSAFlAwQCAwUABEAL+T/1HgIh
# ky/k2WmjVUn5VDCEtcFS/10fLQsQ/U5T7LpwCOZJ3wXD+ET68KABe9FPom/EF7Er
# fg/e0I+h3SCaoIIScjCCBd8wggTHoAMCAQICEE5A5DdU7eaMAAAAAFHTlH8wDQYJ
# KoZIhvcNAQELBQAwgb4xCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1FbnRydXN0LCBJ
# bmMuMSgwJgYDVQQLEx9TZWUgd3d3LmVudHJ1c3QubmV0L2xlZ2FsLXRlcm1zMTkw
# NwYDVQQLEzAoYykgMjAwOSBFbnRydXN0LCBJbmMuIC0gZm9yIGF1dGhvcml6ZWQg
# dXNlIG9ubHkxMjAwBgNVBAMTKUVudHJ1c3QgUm9vdCBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eSAtIEcyMB4XDTIxMDUwNzE1NDM0NVoXDTMwMTEwNzE2MTM0NVowaTEL
# MAkGA1UEBhMCVVMxFjAUBgNVBAoMDUVudHJ1c3QsIEluYy4xQjBABgNVBAMMOUVu
# dHJ1c3QgQ29kZSBTaWduaW5nIFJvb3QgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkg
# LSBDU0JSMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKeBj/cURbZi
# Q/LYrtMlXkhPUb/FfZ9QHDXR1n5hKpQZbSdGpKYaXfdUUWqAIsaoZnVNVIPJXmgb
# q/ZbZLCtrSC9VO9Ga20C50WudfaOirkyLou4dxxSTXmIX6U6GMlQLJcnLb/aAH1j
# f+8y7EaHY9uan8NaITZ7+ZvVyqBuciz84fGecE0IVhVvkKv7SLq518GCeIVlLn+1
# ycDiFLc3EUEG4orgqPblfrZ4BQHDYO1PB0EuChNJ45Cbf929+qy/ZFHRXJu09Vzn
# XP87m6WgGtd9CbLCt/9uHLzIfebpK/xysxTpSlUShJxEJXUd9irwT6UgPWgl62GX
# fA/ltj3zrsPBEbwbjszgRzBeQgCGceNYrAbKZR97lKZLV2cMfl6teGdbVeNe68fY
# 7Exuhsvz3Pifh6pyWBIPfab4+EI5Ozws5DJNSYzg4QDCOKCc+oQ+QdxuVq7GGlv0
# Z2gFAc0bv66HvJ1T9i7otmvkmd7FT4dYqNJlHsgf1XJu7lkcVzsJcp3XyreQxs17
# RZKRQgNMfT/K8qq4wg6G8xCfRi6kZoZoWmgYcCk4EYBga4pDo3Ns47NrN//mnWcB
# kobfL0jR+1Bg1Vz+IdMBQmP+73C0F8CPqO7TwUtfEur9/S4Oh0Rg46n0whij4/3O
# DIQiDfOneNqT89s4z7kvM8b/BzxevkXTAgMBAAGjggErMIIBJzAOBgNVHQ8BAf8E
# BAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHSUEFjAUBggrBgEFBQcDAwYI
# KwYBBQUHAwgwOwYDVR0gBDQwMjAwBgRVHSAAMCgwJgYIKwYBBQUHAgEWGmh0dHA6
# Ly93d3cuZW50cnVzdC5uZXQvcnBhMDMGCCsGAQUFBwEBBCcwJTAjBggrBgEFBQcw
# AYYXaHR0cDovL29jc3AuZW50cnVzdC5uZXQwMAYDVR0fBCkwJzAloCOgIYYfaHR0
# cDovL2NybC5lbnRydXN0Lm5ldC9nMmNhLmNybDAdBgNVHQ4EFgQUgrrWPZfOn89x
# 6JI3r/2ztWk1V88wHwYDVR0jBBgwFoAUanImetAe733nO2lR1GyNn5ASZqswDQYJ
# KoZIhvcNAQELBQADggEBAB9eQQS2g3AkUyxVcx1lOsDstHsEmF5ZOBMJpFmUQl5Q
# v09sbiUgkJNYQA31GbRi7iRewgFYFQIdEAlvqNT7kn43OD4vFH2PHUM2ZLNmE18U
# zKVx91shS8aXvtyV/HB9ERzTId3QJDkpxf4KGqXPe3nuOm/e3L/pEd0WgwjTLI1/
# TagUeS8FYVI462DzFGh9y7KKrcCUXOQmDiyK3UbDzuRWUcVW44W4TZtFcosH8Yr7
# Sbhf0fKWgV1pUiTxCCPS1iMP64vXfovBk2v68WJ7WOlQm5duF4gN4cZDmNeBYbaF
# nUfssZ6uPyA7Q53Yohzg1HwIwq92BvhiZnq29/rIrzUwggYXMIID/6ADAgECAhAF
# Rrrgye8Bm6BABnPMA9IzMA0GCSqGSIb3DQEBDQUAME8xCzAJBgNVBAYTAlVTMRYw
# FAYDVQQKEw1FbnRydXN0LCBJbmMuMSgwJgYDVQQDEx9FbnRydXN0IENvZGUgU2ln
# bmluZyBDQSAtIE9WQ1MyMB4XDTI0MDIyMTE2MzUzOVoXDTI1MDEyNDE2MzUzOFow
# gZMxCzAJBgNVBAYTAlVTMQ4wDAYDVQQIEwVUZXhhczETMBEGA1UEBxMKUm91bmQg
# Um9jazEfMB0GA1UEChMWRGVsbCBUZWNobm9sb2dpZXMgSW5jLjEdMBsGA1UECxMU
# U3VwcG9ydEFzc2lzdCBDbGllbnQxHzAdBgNVBAMTFkRlbGwgVGVjaG5vbG9naWVz
# IEluYy4wggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCmAU+pJ0mDLeIE
# h42ZctGdDVOf1N1O3YqMxkRWSDti30ibwWFir1QhUy+Q/GUxvbccF0fZ1wlS8sDU
# BQMGQerSsi8O/k9bousJxiFRFw4AIY7j8N5kSrnjkaKJpD2lvHN4TkxgJ5iwMaoj
# Yc4tw77a6HNNMqzWiPL6lSYA3nw94GZIfOj4a6G3z+GteeZzDbIKrhd0VVxA9Fq3
# b5jtEyrmVFkyHkbEZTjpjO8DVs5odinjLPoFEXkfF3/Odn32zfxr2qPlqvQc/RjR
# E0gJUUSGmBMS/28pA92pQ230VQCiGmgpW05/QA15bVSJRcgDEd5Q5DKL+447/Ump
# h4CZBEm3mi6rj0E70rzGHZEVMawzrzcHdg8pReDUsWw8q8QEkwtdbHzImjr4G+ct
# jdqy4LM42ZaniNuPwVoxKtakRkYZ8gwQ2oPeSvf3ESRUBoriFZdklAXpDtAoyK3J
# ghzsKK+keDiDdfllwDu8L+mdiRRAFMyIQyKzDg6tScq1fveygOUCAwEAAaOCASgw
# ggEkMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFKMO8UrF8Vv9fjvlpWqAzwwHL1XJ
# MB8GA1UdIwQYMBaAFO+funmwc/IlHnicA1KcG1OE3o3tMGcGCCsGAQUFBwEBBFsw
# WTAjBggrBgEFBQcwAYYXaHR0cDovL29jc3AuZW50cnVzdC5uZXQwMgYIKwYBBQUH
# MAKGJmh0dHA6Ly9haWEuZW50cnVzdC5uZXQvb3ZjczItY2hhaW4ucDdjMDEGA1Ud
# HwQqMCgwJqAkoCKGIGh0dHA6Ly9jcmwuZW50cnVzdC5uZXQvb3ZjczIuY3JsMA4G
# A1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzATBgNVHSAEDDAKMAgG
# BmeBDAEEATANBgkqhkiG9w0BAQ0FAAOCAgEAFjzIULqaGH6/S+XggyvGQbTB0tnY
# r+5LSvvuH3JpdXYgU2cBhPYL/0T//MYEI/vlXLMTxfLuSY/E4RLlGBzJjsksZ0R/
# mzUhJKmnSLrDonXYi9HqeFilLH9uXg4/V4yw+Hh9XtJn7QmLEpOeHJhw63Izy4aa
# teglRr2qA/YdW+cMCmfP8+kCzuQYnwVcndFAx8t1It19GAwDPOZOW5jmMI4fX5pA
# fMVG8YZWp3krRhm5jMdhOVh8UNF5S/M+uSzRIK0JTVhapINjzJfFmDT5ChFK5no0
# J+rrV7C1fsFdxZrfcc7fZ9+J2O4s+StvU2OzluGQZY29bPuO2nTpLmoA8L9vss/q
# 7122C8Fa8d69X13/+Hyxhigz1UHZjDUTo200cnENIEoGZjnZQrHuNREaDSR269N9
# tKereqAqKXKQdgbDhCkVdRd9tM8wG8vU4+/0J4Jg/Cucxt0rRe8U2ISWkor7muHQ
# X7BTddiSSocCmzBUNaotKm5II+Y6VEX+cupck1EhbLhv7JKTEI7qkQnstSHozj+z
# L/elN1cJVuDyhM40IdDJYEqT1qbwkcxedwjzqD+k4OqIPBttUtaHJXuKGPTrSsvY
# nEYCd4BqEByRaksLnroSwr9nqwzA0YQC2O49zTMvCimtgnyYkzLf7QqKo4911QXy
# km8YLHmk9RcsR+wwggZwMIIEWKADAgECAhBx71V0rzVUw1osafZvS2vNMA0GCSqG
# SIb3DQEBDQUAMGkxCzAJBgNVBAYTAlVTMRYwFAYDVQQKDA1FbnRydXN0LCBJbmMu
# MUIwQAYDVQQDDDlFbnRydXN0IENvZGUgU2lnbmluZyBSb290IENlcnRpZmljYXRp
# b24gQXV0aG9yaXR5IC0gQ1NCUjEwHhcNMjEwNTA3MTkyMDQ1WhcNNDAxMjI5MjM1
# OTAwWjBPMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNRW50cnVzdCwgSW5jLjEoMCYG
# A1UEAxMfRW50cnVzdCBDb2RlIFNpZ25pbmcgQ0EgLSBPVkNTMjCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAJ6ZdhcanlYXCGMsk02DYYQzNAK22WKg3sIO
# uSBMyFedD91UWw0M1gHdL0jhkQnh28gVBIK2e/DY1jA7GXFw+6iml/YpXaQMqfRT
# PlfbDE5u/HbbXyTpql9D45PnDs/KJbzETDALWg/mBvTlbgyZZlhPg2HCc3xcIm8B
# RcUP90BPZEvQFwqpDh4CL6GPTPJnUNs+5J/CTz906zGk0JTQmbwwkglqyyTNoth2
# UtBOdZhPZFrSXoP0WMBdanXE2D9kOosUDdh24eq5a+cRcEkROGMTbvHG+r0QRTUH
# 5nYV0HUWqsJDV/6r/mNzRiKguPPkx3BGCfmpN0Gas0tsH3Byowf2NZJ0EWRu+QLV
# wJKV8ZdZfg3uoiXycVW4m42/ze6u3fsM564yTlCNod/Rc7/Bzn912qu/0K2COMXn
# iO2ibTqGEbfXsOGoizsMQReaX+RbmMidAJ/3c9LD6Z8Fh3khg9YL7dHMCJ/g8cXJ
# WLpTX9SHsYtZqNJezWnQPvrEOQmvtLXt5zz6IofWc/kXlWrDHPVVeF/U+gvAWz+M
# eBUOWkw6buUmmNAnzCDfwIY7eo1lRn7ZYV6p9K4+1PyvRcc6s4UESovICV2zewIo
# WeOGfYCiWEBmYuA4VYOrnylBJrq76dhk+La7KHPNFUrXnnPjZkyxUZ2BI4vIhney
# tiw3InAhAgMBAAGjggEsMIIBKDASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQW
# BBTvn7p5sHPyJR54nANSnBtThN6N7TAfBgNVHSMEGDAWgBSCutY9l86fz3Hokjev
# /bO1aTVXzzAzBggrBgEFBQcBAQQnMCUwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3Nw
# LmVudHJ1c3QubmV0MDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly9jcmwuZW50cnVz
# dC5uZXQvY3NicjEuY3JsMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzBFBgNVHSAEPjA8MDAGBFUdIAAwKDAmBggrBgEFBQcCARYaaHR0cDovL3d3
# dy5lbnRydXN0Lm5ldC9ycGEwCAYGZ4EMAQQBMA0GCSqGSIb3DQEBDQUAA4ICAQBe
# 84aZNcF57vAQr9eSQ9KF0FvgmKDgcVHJFMtQmmAOsAQmSbHP6bqbCKHaQ13UbyOi
# ufhAx0f+TQELSJA/yNxqtD5TNSi+QEpHhWoed0DMgH9htDxPeajmo6agfkSGcb8S
# G5WBcvcNpdDeZ5/Gorjxavn8/nRmxmTmeT1qA2FOSx/MIGLLAhjsY+1+cT+Wugte
# aCJn7B/A0gUWZrGypOr8xZWjjRKl9Y3vGyDNmffnMvNZcR/dlOZ55VIjEFYq/Fk4
# v795JZJqx/2rZ3dxsQR9Na0UwT6o/CMXVggYfNd6ImuRasw1RW1PO51DnQW4nfP8
# NCFcBBgyVzg0wcqDI0amiCMhxn4UgKux77sLrAk/7lORMbPiVESqtX0wPCwjnOg/
# o1jqQAgXoyBfesAM26r/AxYDDXRkIpqUXjA1dhP10+Hj4AfK2epFiEacVNUQ4vMy
# CUC251wXMv7Mr+ttz2A8dfPuXGBAVRu1Wa9yI2hNnHQEDBDJr1Bbpw1mD5blmpXg
# IKIa0LDuOEmeKmeekZZsmNvEEG1gfB5uSOe2fq8zBxJx772VO76pg9RCfbenNNdf
# hpG1r1ZY2lV9F73bvM1kQRWNMVEGT7Qusos9nPNN41gDVMysiPhSPE5LRgklGf8V
# 56eYRi59uurj43z/+bkZlb52uQ15sgJRGkrIn4jCQzGCF/8wghf7AgEBMGMwTzEL
# MAkGA1UEBhMCVVMxFjAUBgNVBAoTDUVudHJ1c3QsIEluYy4xKDAmBgNVBAMTH0Vu
# dHJ1c3QgQ29kZSBTaWduaW5nIENBIC0gT1ZDUzICEAVGuuDJ7wGboEAGc8wD0jMw
# DQYJYIZIAWUDBAIDBQCggZwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwTwYJ
# KoZIhvcNAQkEMUIEQEUrHUmmlEVsRi8WH7Z1onRX0RPA4LQLAC+7iwiTG9SVGCRs
# 6NQrcwtPR6sOufQXE/rRv0BvGhcuBcqAz87IingwDQYJKoZIhvcNAQEBBQAEggGA
# ekOH939m/qK+CdzrnzRB95nmKL5mSAGw7jsWUXMlmhc6rLKhpDg07+Lg6iU6uCaY
# koriv9vbOmWoCZAa0EiSHMnSmTgc3enLoVm2JMgwOY0BcRiG58sECrtKJbemfAK/
# e62gc7+mtzJdaYF43warFHuTOzdvSdBGoW8fkynpDyhx1CNV+lZ4vVJ8yRAECltQ
# WeDZPEFxqIX6SbG819eY0NO7cGjLckbwnp6siqitm1m6083IKdouJGYRExlpuZql
# qeoJ/eH5rNkIkpK6oS7wEl+DqPnJDuJCHRaUU11dzwJ6UoM1LFibECp4WV0sb0oU
# WRpeBqg6hvN+J1JJq1My/zGZ3G6WY4pYElNyhkyVVLW7OvVQiV0ey/hpJs7e7xZt
# xx1nNAx+JcYiHfc7exqGmpGK9fywxlzozrnA3ovIzgSthtNUoMyqPY03Ex7ZiS/G
# USGWTARTQv0b9F+JUYmcz3mYvb7YbarIMbZMUnor+BJge9/mKxi1ViWDA0hwJCcx
# oYIVTjCCFUoGCisGAQQBgjcDAwExghU6MIIVNgYJKoZIhvcNAQcCoIIVJzCCFSMC
# AQMxDTALBglghkgBZQMEAgEwggEVBgsqhkiG9w0BCRABBKCCAQQEggEAMIH9AgEB
# BgpghkgBhvpsCgMFMFEwDQYJYIZIAWUDBAIDBQAEQP1ZYJxLA9dYkyiBFPQaVu4F
# +iMKi62d0ewj9nEDA4JrurYeGk56IAQNyTmfPnR4I37u5J96585uZp7hMVASPSgC
# CBt24BUDSMpKGA8yMDI0MDkxMTA2NDYzM1owAwIBAaB5pHcwdTELMAkGA1UEBhMC
# Q0ExEDAOBgNVBAgTB09udGFyaW8xDzANBgNVBAcTBk90dGF3YTEWMBQGA1UEChMN
# RW50cnVzdCwgSW5jLjErMCkGA1UEAxMiRW50cnVzdCBUaW1lc3RhbXAgQXV0aG9y
# aXR5IC0gVFNBMaCCD1gwggQqMIIDEqADAgECAgQ4Y974MA0GCSqGSIb3DQEBBQUA
# MIG0MRQwEgYDVQQKEwtFbnRydXN0Lm5ldDFAMD4GA1UECxQ3d3d3LmVudHJ1c3Qu
# bmV0L0NQU18yMDQ4IGluY29ycC4gYnkgcmVmLiAobGltaXRzIGxpYWIuKTElMCMG
# A1UECxMcKGMpIDE5OTkgRW50cnVzdC5uZXQgTGltaXRlZDEzMDEGA1UEAxMqRW50
# cnVzdC5uZXQgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgKDIwNDgpMB4XDTk5MTIy
# NDE3NTA1MVoXDTI5MDcyNDE0MTUxMlowgbQxFDASBgNVBAoTC0VudHJ1c3QubmV0
# MUAwPgYDVQQLFDd3d3cuZW50cnVzdC5uZXQvQ1BTXzIwNDggaW5jb3JwLiBieSBy
# ZWYuIChsaW1pdHMgbGlhYi4pMSUwIwYDVQQLExwoYykgMTk5OSBFbnRydXN0Lm5l
# dCBMaW1pdGVkMTMwMQYDVQQDEypFbnRydXN0Lm5ldCBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eSAoMjA0OCkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCt
# TUupEoay6qMgBxUWZCorS9G/C0pNju2AdqVnt3hAwHNCyGjA21Mr3V64dpg1k4sa
# nXwTOg4fW7cez+UkFB6xgamNfbjMa0sD8QIM3KulQCQAf3SUoZ0IKbOIC/WHd51V
# zeTDftdqZKuFFIaVW5cyUG89yLpmDOP8vbhJwXaJSRn9wKi9iaNnL8afvHEZYLgt
# 6SzJkHZme5Tir3jWZVNdPNacss8pA/kvpFCy1EjOBTJViv2yZEwO5JgHddt/37kI
# VWCFMCn5e0ikaYbjNT8ehl16ehW97wCOFSJUFwCQJpO8Dklokb/4R9OdlULBDk3f
# bybPwxghYmZDcNbVwAfhAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMB
# Af8EBTADAQH/MB0GA1UdDgQWBBRV5IHREYC+2Im5CKMx+aEkCRa5cDANBgkqhkiG
# 9w0BAQUFAAOCAQEAO5uPVpsw51OZfHp5p02X1xmVkPsGH8ozfEZjj5ZmJPpAGyEn
# yuZyc/JP/jGZ/cgMTGhTxoCCE5j6tq3aXT3xzm72FRGUggzuP5WvEasP1y/eHwOP
# VyweybuaGkSV6xhPph/NfVcQL5sECVqEtW7YHTrh1p7RbHleeRwUxePQTJM7ZTzt
# 3z2+puWVGsO1GcO9Xlu7/yPvaBnLEpMnXAMtbzDQHrYarN5a99GqqCem/nmBxHmZ
# M1e6ErCp4EJsk8pW3v5thAsIi36N6teYIcbz5zx5L16c0UwVjeHsIjfMmkMLl9yA
# kI2zZ5tvSAgVVs+/8St8Xpp26VmQxXyDNRFlUTCCBRMwggP7oAMCAQICDFjaE/8A
# AAAAUc4N9zANBgkqhkiG9w0BAQsFADCBtDEUMBIGA1UEChMLRW50cnVzdC5uZXQx
# QDA+BgNVBAsUN3d3dy5lbnRydXN0Lm5ldC9DUFNfMjA0OCBpbmNvcnAuIGJ5IHJl
# Zi4gKGxpbWl0cyBsaWFiLikxJTAjBgNVBAsTHChjKSAxOTk5IEVudHJ1c3QubmV0
# IExpbWl0ZWQxMzAxBgNVBAMTKkVudHJ1c3QubmV0IENlcnRpZmljYXRpb24gQXV0
# aG9yaXR5ICgyMDQ4KTAeFw0xNTA3MjIxOTAyNTRaFw0yOTA2MjIxOTMyNTRaMIGy
# MQswCQYDVQQGEwJVUzEWMBQGA1UEChMNRW50cnVzdCwgSW5jLjEoMCYGA1UECxMf
# U2VlIHd3dy5lbnRydXN0Lm5ldC9sZWdhbC10ZXJtczE5MDcGA1UECxMwKGMpIDIw
# MTUgRW50cnVzdCwgSW5jLiAtIGZvciBhdXRob3JpemVkIHVzZSBvbmx5MSYwJAYD
# VQQDEx1FbnRydXN0IFRpbWVzdGFtcGluZyBDQSAtIFRTMTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBANkj5hSk6HxLhXFY+/iB5nKLXUbDiAAfONCK4dZu
# VjDlr9pkUH3CEzn7vWa02oT7g9AoH8t26GBQaZvzzk8T4sE+wd8SyzKj+F5EIg7M
# OumNSblgdMjeVD1BXkNfKEapprfKECsivFtNW4wXZRKG/Sx31cWgjMrCg+BHV3zn
# cK5iRScxGArUwKQYVVL3YMYES7PdaDJuEB80EbgSeGTx7qng9+OxIo80WmXLivTh
# RVB035OXpjTm0Ew7nzdJUqdTTp8uZ1ztlvylv3RRiOOqjr3ZsS9fUDAW9FFgImuZ
# y//hVDu5+0Q4pQg5I5tpR/o8xNDnqt9GsuzyihmsKbI4lXUCAwEAAaOCASMwggEf
# MBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgEGMDsGA1UdIAQ0MDIw
# MAYEVR0gADAoMCYGCCsGAQUFBwIBFhpodHRwOi8vd3d3LmVudHJ1c3QubmV0L3Jw
# YTAzBggrBgEFBQcBAQQnMCUwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLmVudHJ1
# c3QubmV0MDIGA1UdHwQrMCkwJ6AloCOGIWh0dHA6Ly9jcmwuZW50cnVzdC5uZXQv
# MjA0OGNhLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAdBgNVHQ4EFgQUw8Jx0nvX
# aAWuOzmbNCUMYgPHV2gwHwYDVR0jBBgwFoAUVeSB0RGAvtiJuQijMfmhJAkWuXAw
# DQYJKoZIhvcNAQELBQADggEBAB0k55p0W6pw/LEOMUXXLAB/ZjoroJo0qqxjbYn5
# n98Nd/0kI/xPnLdvj/P0H7bB/dYcxIyIZsFjjbpXd9O4Gh7IUa3MYDYah2oo6hFl
# 3sw8LIx0t+hQQ9PMKOgVbBEqnxSVKckFV7VnNug8qYPvQcEhFtN+9y0RR2Z2YIIS
# aYx2VXMP3y9LXelsI/gH9rV91mlFnFh9YS78eEtDTomRRkQsoFOoRaH2Fli7kRPy
# S8XfC8Dnril6vUWz53Aw5zSO63r207XR3msTmUazi9JNk3W18W+/3AAowiW/vOej
# ZTTsPw0dl4z6qogipBg12wWOduMQyCmPY9CurBjZ2sSfURIwggYPMIIE96ADAgEC
# AhAH1xNT2iVhtGHpkEeKTM4EMA0GCSqGSIb3DQEBCwUAMIGyMQswCQYDVQQGEwJV
# UzEWMBQGA1UEChMNRW50cnVzdCwgSW5jLjEoMCYGA1UECxMfU2VlIHd3dy5lbnRy
# dXN0Lm5ldC9sZWdhbC10ZXJtczE5MDcGA1UECxMwKGMpIDIwMTUgRW50cnVzdCwg
# SW5jLiAtIGZvciBhdXRob3JpemVkIHVzZSBvbmx5MSYwJAYDVQQDEx1FbnRydXN0
# IFRpbWVzdGFtcGluZyBDQSAtIFRTMTAeFw0yNDAxMTkxNjQ2MjhaFw0yOTA2MDEw
# MDAwMDBaMHUxCzAJBgNVBAYTAkNBMRAwDgYDVQQIEwdPbnRhcmlvMQ8wDQYDVQQH
# EwZPdHRhd2ExFjAUBgNVBAoTDUVudHJ1c3QsIEluYy4xKzApBgNVBAMTIkVudHJ1
# c3QgVGltZXN0YW1wIEF1dGhvcml0eSAtIFRTQTEwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQDHkjhBOf+gP19NTYqXMeObh8N4BWk2C1KzqoNdsNK9fr6D
# oF9enpfz2zUXqfnbFWJ8yvbFyTQV4hGlkrEu4GlUXQ4rvlXGAYyFY7JJLTVf5U5D
# xHELpLQeNE3/Rcj+T+Ew6OllbGtl077ULGjQrQSbarnQVPs1AJAxxthoal2v6n7Q
# +Z0T786dY2RCcgeF+wYxi+OdC6bVMttSpU4MPMHAmtF/AndjE83zPTweAks2huAE
# tHh35Jsv4Ykq3oJd6+Qa3I26e6Sfj45sdesD4IAEv7EJHPpherObgbcLyRMKeO0I
# 9symX0JHEjpHeHb+vNqZP2TrN14q31LimbD974TKkTqisKextlYcP0T4fpHveKYk
# /t4pHvj191F/tngth7S9ALnGHuDo4RPu7l/XXu6kfHVgzqE1kFjCq7VIQ3vpx3eJ
# iYvGoYxpl89uekP+9F/7Y+Uk6t/gEJCnEpDMG60IitGNhSCibqGLFieVMdPPbgMp
# n0TCJwist/SJTTfkJYlaUyxTDYIUc8bsxbDZh9ibEu4mOl+XL3DJMHihWkpt0khK
# D1VqfvZb4odf2hEbd74aXvdICphxDH2uKoF9sp6RYA7R2WowEorkmuymS2+FBkkQ
# DoVIPy7mFM9a4084Kq/XMQC8LJaVkq1zz3ocUcv+LenALlgOChVly4h7MhtgDQID
# AQABo4IBWzCCAVcwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUQ2gfb58i0PhfCff8
# uOUjxo4HQpIwHwYDVR0jBBgwFoAUw8Jx0nvXaAWuOzmbNCUMYgPHV2gwaAYIKwYB
# BQUHAQEEXDBaMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5lbnRydXN0Lm5ldDAz
# BggrBgEFBQcwAoYnaHR0cDovL2FpYS5lbnRydXN0Lm5ldC90czEtY2hhaW4yNTYu
# Y2VyMDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly9jcmwuZW50cnVzdC5uZXQvdHMx
# Y2EuY3JsMA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBC
# BgNVHSAEOzA5MDcGCmCGSAGG+mwKAQcwKTAnBggrBgEFBQcCARYbaHR0cHM6Ly93
# d3cuZW50cnVzdC5uZXQvcnBhMA0GCSqGSIb3DQEBCwUAA4IBAQC+sNz9vPpmp/wj
# HfPZV2L0JN8dL/lYy8rMDH3Pbof1boJaK97jX8bOGuQIr44EAR7/AvgFU7ioYoV7
# matFe9mqsReD0Sl+kyHoNohCITj7+w2BycOKjMoqXmav+Zz0jXwS+3ptOoqwAPc7
# cKUPu7VTqeHGKSbq3BJKL11aBLiq44cLfcieBv5pZkuOp/S+MMml4pChqIENPkch
# klBdMuTyVs+plCG7MMJ3GBGaJq7x4j4v/D+JMzddlOfdGsXlzGZs+gDOluKA7fgs
# p8VoE2l8BEStCNX5q8mtF2bVLwtX8JvPXB6rDSdGaf6otwUljuCyFTNKX7qci9Ao
# CTy1hbLhMYIEmDCCBJQCAQEwgccwgbIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1F
# bnRydXN0LCBJbmMuMSgwJgYDVQQLEx9TZWUgd3d3LmVudHJ1c3QubmV0L2xlZ2Fs
# LXRlcm1zMTkwNwYDVQQLEzAoYykgMjAxNSBFbnRydXN0LCBJbmMuIC0gZm9yIGF1
# dGhvcml6ZWQgdXNlIG9ubHkxJjAkBgNVBAMTHUVudHJ1c3QgVGltZXN0YW1waW5n
# IENBIC0gVFMxAhAH1xNT2iVhtGHpkEeKTM4EMAsGCWCGSAFlAwQCAaCCAaUwGgYJ
# KoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yNDA5MTEw
# NjQ2MzNaMCkGCSqGSIb3DQEJNDEcMBowCwYJYIZIAWUDBAIBoQsGCSqGSIb3DQEB
# CzAvBgkqhkiG9w0BCQQxIgQgt948SMsZhNnZ3thMN4VUznm2fmABRHy9DsQnnH+L
# eqQwggELBgsqhkiG9w0BCRACLzGB+zCB+DCB9TCB8gQgKEn3MRjXQUUFYXPNPuzL
# vVNLXg7w+gYWjbDic0kD7o8wgc0wgbikgbUwgbIxCzAJBgNVBAYTAlVTMRYwFAYD
# VQQKEw1FbnRydXN0LCBJbmMuMSgwJgYDVQQLEx9TZWUgd3d3LmVudHJ1c3QubmV0
# L2xlZ2FsLXRlcm1zMTkwNwYDVQQLEzAoYykgMjAxNSBFbnRydXN0LCBJbmMuIC0g
# Zm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxJjAkBgNVBAMTHUVudHJ1c3QgVGltZXN0
# YW1waW5nIENBIC0gVFMxAhAH1xNT2iVhtGHpkEeKTM4EMAsGCSqGSIb3DQEBCwSC
# AgA3I6wEPvQ2duo21ZccYa4GkF383RwfNDNbx79i32UZjSObQDjn2gHkH1zXZBCl
# dl0D7JH9wCWWRG1S8g5LZyzl3fGpcjv4baPFRlIbtePiqNx0RI9flCVJ+avtIxUW
# 4O727+bdkIFFYjGQgYAIZBcAm/TQlPc3xOXxCqJPedL55kpFsEjUtSp+8VmLOLPV
# XeAMEGPM7vtdxSh63wbyW9W9UE8oFoAUK8cpW27Nu9CF0CFt9LZNpwcPkk5Q6VIZ
# F90DTqk56ViVeUiHSZsV5Kbrv4tYLHt57MlYnuyQ7Wdb1TNS0Rdn0uOIE/3A9SUM
# 5t1IpkwAL22Q+j+LWIjtsB0KLqPn/YTJGxhZZCQmWeq73RBUFMp//oLrMhYBIrjb
# nC8TUSa6DIKbmT2kyr+TnuEAmfe93uurBGhfjNZjNbLsOPW1lPr2toy1XAq2wlJo
# EAKt95McwWLyVdgf39I4SmEEPnNmljIcGiHWdkJx8uxySx3Ka5siWVtZkEoUZQRZ
# /9mSp6MpKwRQj5gozKqLUB+14og93K2vhAdKF78c0Zokd610wefyJwAY1wuvDTX9
# BMqBdynhqHDk/YUAI3RP6n2eQOq9SGXr3SVO+8FdKXN3rGtDgjvwVNo/BOCKGITg
# HJHc+7flUcQ0ngeVU4b/vGzHEI43jhVt+xiC6d+DGOEIsA==
# SIG # End signature block
