# traefikee-windows

> **!! Warning !!**
> <br>
> This setup do not contain the registry configuration.

## Prepare nodes

### On Both nodes

Create Traefikee Folder to store everything:

```powershell
mkdir C:\traefikee
cd C:\traefikee
```

Download TraefikEE binary for Windows:

```powershell
Invoke-WebRequest -Uri "https://s3.amazonaws.com/traefikee/binaries/v2.10.1/traefikee_v2.10.1_windows_amd64.zip" -OutFile "traefikee_v2.10.1_windows_amd64.zip"
```

Unzip archive content:

```powershell
Expand-Archive -Path traefikee_v2.10.1_windows_amd64.zip 
```

Move TraefikEE binary in the right folder:
```powershell
mv .\traefikee_v2.10.1_windows_amd64\traefikee.exe .
```

Clean up archive:
```powershell
rmdir .\traefikee_v2.10.1_windows_amd64 -r -fo
rm .\traefikee_v2.10.1_windows_amd64.zip
```

### On the controller node

Copy **controller.ps1** on the controller node wherever you want.
Copy **static.yaml** in *C:\traefikee*.

Execute firewall.ps1 command:

```powershell
New-NetFirewallRule -DisplayName "Allow TraefikEE connections" -Direction Inbound -Program "C:\traefikee\traefikee.exe" -Action Allow
```

Then start Traefikee controller by executing **controller.ps1**

Check logs in *C:\traefikee\log\traefikee.log* if the controller has started correctly.
If everything is OK you should find 2 files in *C:\traefikee\secrets* one named proxy and the other one controller.
The proxy file contains the token needed for connection of the proxies to the controller.
Let's copy it in the same path on the proxy nodes.

### On the proxy node

Copy **proxy.ps1** on the controller node wherever you want.
Verify that you have copied the proxy token file in *C:\traefikee\secrets*

Execute firewall.ps1 command:

```powershell
New-NetFirewallRule -DisplayName "Allow TraefikEE connections" -Direction Inbound -Program "C:\traefikee\traefikee.exe" -Action Allow
```

Then start Traefikee proxy by executing **proxy.ps1**

Check logs in *C:\traefikee\log\traefikee.log* if the proxy has started correctly
If everything is OK you should see the proxy applying the static configuration from the logs.

## Connect teectl to TraefikEE cluster

On the controller execute this command:

```powershell
C:\traefikee\traefikee.exe generate credentials --onpremise.hosts="${CONTROLLER_IP}" --cluster=windows --socket="\\.\pipe\teectl.sock" | Out-File -FilePath C:\traefikee\config.yaml
```

Copy the YAML file generate from the controller on your workstation with teectl if needed
Then import configuration in teectl:

```powershell
teectl cluster import --file=config.yaml --force
```

Then select the imported cluster:

```powershell
teectl cluster use windows
```

Finally check if you have access to the cluster:
```powershell
teectl get n  
```

If the port are open and everything is working fine you should get this kine of result:

```
ID                         NAME             STATUS  ROLE
nrv928x0c23m84tf0nxrzqqyz  WIN-4213AT9VT80  Ready   Controller (Leader)
qi557v595gep94z8qkx6d7rv3  WIN-4GT1FEUTXAZ  Ready   Proxy / Ingress
zje0g6gzp3pxkpvtw6lp0tuy5  WIN-4JP9LIUKBEI  Ready   Proxy / Ingress
```

Now deploy the dashboard via teectl file:

```powershell
teectl apply --file dashboard.yaml
```
