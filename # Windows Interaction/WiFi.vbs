Dim fso, tf, tf2, WshShell
On Error Resume Next
strComputer = "."
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Set tf = fso.CreateTextFile("C:\TEMP\BCPS_WiFi.xml", True)
tf.WriteLine ("<?xml version=" & Chr(34) & "1.0" & Chr(34) & "?>")
tf.WriteLine ("<WLANProfile xmlns=" & Chr(34) & "http://www.microsoft.com/networking/WLAN/profile/v1" & Chr(34) & ">")
tf.WriteLine ("    <name>BCPS_WiFi</name>")
tf.WriteLine ("    <SSIDConfig>")
tf.WriteLine ("        <SSID>")
tf.WriteLine ("            <hex>424350535F57694669</hex>")
tf.WriteLine ("            <name>BCPS_WiFi</name>")
tf.WriteLine ("        </SSID>")
tf.WriteLine ("        <nonBroadcast>false</nonBroadcast>")
tf.WriteLine ("    </SSIDConfig>")
tf.WriteLine ("    <connectionType>ESS</connectionType>")
tf.WriteLine ("    <connectionMode>auto</connectionMode>")
tf.WriteLine ("    <autoSwitch>true</autoSwitch>")
tf.WriteLine ("    <MSM>")
tf.WriteLine ("        <security>")
tf.WriteLine ("            <authEncryption>")
tf.WriteLine ("                <authentication>open</authentication>")
tf.WriteLine ("                <encryption>none</encryption>")
tf.WriteLine ("                <useOneX>false</useOneX>")
tf.WriteLine ("            </authEncryption>")
tf.WriteLine ("            <preAuthThrottle>3</preAuthThrottle>")
tf.WriteLine ("        </security>")
tf.WriteLine ("    </MSM>")
tf.WriteLine ("</WLANProfile>")
tf.Close
Set tf2 = fso.CreateTextFile("C:\TEMP\BCPS-Secure.xml", True)
tf2.WriteLine ("<?xml version=" & Chr(34) & "1.0" & Chr(34) & "?>")
tf2.WriteLine ("<WLANProfile xmlns=" & Chr(34) & "http://www.microsoft.com/networking/WLAN/profile/v1" & Chr(34) & ">")
tf2.WriteLine ("    <name>BCPS-Secure</name>")
tf2.WriteLine ("    <SSIDConfig>")
tf2.WriteLine ("        <SSID>")
tf2.WriteLine ("            <hex>424350532D536563757265</hex>")
tf2.WriteLine ("            <name>BCPS-Secure</name>")
tf2.WriteLine ("        </SSID>")
tf2.WriteLine ("        <nonBroadcast>false</nonBroadcast>")
tf2.WriteLine ("    </SSIDConfig>")
tf2.WriteLine ("    <connectionType>ESS</connectionType>")
tf2.WriteLine ("    <connectionMode>auto</connectionMode>")
tf2.WriteLine ("    <autoSwitch>true</autoSwitch>")
tf2.WriteLine ("    <MSM>")
tf2.WriteLine ("        <security>")
tf2.WriteLine ("            <authEncryption>")
tf2.WriteLine ("                <authentication>WPA2</authentication>")
tf2.WriteLine ("                <encryption>AES</encryption>")
tf2.WriteLine ("                <useOneX>true</useOneX>")
tf2.WriteLine ("            </authEncryption>")
tf2.WriteLine ("            <PMKCacheMode>enabled</PMKCacheMode>")
tf2.WriteLine ("            <PMKCacheTTL>720</PMKCacheTTL>")
tf2.WriteLine ("            <PMKCacheSize>128</PMKCacheSize>")
tf2.WriteLine ("            <preAuthMode>enabled</preAuthMode>")
tf2.WriteLine ("            <preAuthThrottle>3</preAuthThrottle>")
tf2.WriteLine ("            <OneX xmlns=" & Chr(34) & "http://www.microsoft.com/networking/OneX/v1" & Chr(34) & ">")
tf2.WriteLine ("                <cacheUserData>true</cacheUserData>")
tf2.WriteLine ("                <heldPeriod>1</heldPeriod>")
tf2.WriteLine ("                <authPeriod>18</authPeriod>")
tf2.WriteLine ("                <startPeriod>5</startPeriod>")
tf2.WriteLine ("                <maxStart>3</maxStart>")
tf2.WriteLine ("                <maxAuthFailures>1</maxAuthFailures>")
tf2.WriteLine ("                <authMode>machineOrUser</authMode>")
tf2.WriteLine ("                <singleSignOn>")
tf2.WriteLine ("                    <type>preLogon</type>")
tf2.WriteLine ("                    <maxDelay>10</maxDelay>")
tf2.WriteLine ("                    <allowAdditionalDialogs>true</allowAdditionalDialogs>")
tf2.WriteLine ("                    <userBasedVirtualLan>true</userBasedVirtualLan>")
tf2.WriteLine ("                </singleSignOn>")
tf2.WriteLine ("                <EAPConfig>")
tf2.WriteLine ("                    <EapHostConfig xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/EapHostConfig" & Chr(34) & ">")
tf2.WriteLine ("                        <EapMethod>")
tf2.WriteLine ("                            <Type xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/EapCommon" & Chr(34) & ">25</Type>")
tf2.WriteLine ("                            <VendorID xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/EapCommon" & Chr(34) & ">0</VendorID>")
tf2.WriteLine ("                            <VendorType xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/EapCommon" & Chr(34) & ">0</VendorType>")
tf2.WriteLine ("                            <AuthorID xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/EapCommon" & Chr(34) & ">0</AuthorID>")
tf2.WriteLine ("                        </EapMethod>")
tf2.WriteLine ("                        <Config xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/EapHostConfig" & Chr(34) & ">")
tf2.WriteLine ("                            <Eap xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1" & Chr(34) & ">")
tf2.WriteLine ("                                <Type>25</Type>")
tf2.WriteLine ("                                <EapType xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV1" & Chr(34) & ">")
tf2.WriteLine ("                                    <ServerValidation>")
tf2.WriteLine ("                                        <DisableUserPromptForServerValidation>false</DisableUserPromptForServerValidation>")
tf2.WriteLine ("                                        <ServerNames></ServerNames>")
tf2.WriteLine ("                                        <TrustedRootCA>25 86 73 29 be 40 4f 2d 17 2e d7 a4 41 c6 96 34 76 7e 35 92 </TrustedRootCA>")
tf2.WriteLine ("                                        <TrustedRootCA>25 86 73 29 be 40 4f 2d 17 2e d7 a4 41 c6 96 34 76 7e 35 92 </TrustedRootCA>")
tf2.WriteLine ("                                    </ServerValidation>")
tf2.WriteLine ("                                    <FastReconnect>true</FastReconnect>")
tf2.WriteLine ("                                    <InnerEapOptional>false</InnerEapOptional>")
tf2.WriteLine ("                                    <Eap xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1" & Chr(34) & ">")
tf2.WriteLine ("                                        <Type>26</Type>")
tf2.WriteLine ("                                        <EapType xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1" & Chr(34) & ">")
tf2.WriteLine ("                                            <UseWinLogonCredentials>true</UseWinLogonCredentials>")
tf2.WriteLine ("                                        </EapType>")
tf2.WriteLine ("                                    </Eap>")
tf2.WriteLine ("                                    <EnableQuarantineChecks>false</EnableQuarantineChecks>")
tf2.WriteLine ("                                    <RequireCryptoBinding>false</RequireCryptoBinding>")
tf2.WriteLine ("                                    <PeapExtensions>")
tf2.WriteLine ("                                        <PerformServerValidation xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2" & Chr(34) & ">true</PerformServerValidation>")
tf2.WriteLine ("                                        <AcceptServerName xmlns=" & Chr(34) & "http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2" & Chr(34) & ">false</AcceptServerName>")
tf2.WriteLine ("                                    </PeapExtensions>")
tf2.WriteLine ("                                </EapType>")
tf2.WriteLine ("                            </Eap>")
tf2.WriteLine ("                        </Config>")
tf2.WriteLine ("                    </EapHostConfig>")
tf2.WriteLine ("                </EAPConfig>")
tf2.WriteLine ("            </OneX>")
tf2.WriteLine ("        </security>")
tf2.WriteLine ("    </MSM>")
tf2.WriteLine ("</WLANProfile>")
tf2.Close
ReturnCode = WshShell.Run("netsh wlan add profile filename=" & Chr(34) & "C:\TEMP\BCPS-Secure.xml" & Chr(34), 7, True)
ReturnCode2 = WshShell.Run("netsh wlan add profile filename=" & Chr(34) & "C:\TEMP\BCPS_WiFi.xml" & Chr(34), 7, True)
fso.DeleteFile "C:\TEMP\BCPS-Secure.xml"
fso.DeleteFile "C:\TEMP\BCPS_WiFi.xml"