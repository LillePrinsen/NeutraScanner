# =====================================================================
#  NeutraScan v1.0 - Corporate Network Scanner / Identity / Messaging
#  Slogan: Scan. Identify. Control.
#  by littlleprince
#  Discord: littlleprince
#  Contact: neutracocontact@gmail.com
#  Website: https://neutraco.vercel.app/
# =====================================================================

$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSta   = [System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA'

if (-not $isAdmin -or -not $isSta) {
    $pwsh = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source
    if (-not $pwsh) { $pwsh = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" }
    $args = "-NoProfile -ExecutionPolicy Bypass -STA -File `"$PSCommandPath`""
    try { Start-Process -FilePath $pwsh -ArgumentList $args -Verb RunAs } catch {}
    exit
}

$Global:ErrorLog = Join-Path $env:TEMP 'NeutraScan-error.log'
trap {
    $msg = "NeutraScan fatal error at $(Get-Date)`r`n$_`r`n$($_.ScriptStackTrace)"
    try { $msg | Out-File -FilePath $Global:ErrorLog -Encoding UTF8 -Append } catch {}
    try { [System.Windows.MessageBox]::Show("NeutraScan crashed.`n`n$($_.Exception.Message)`n`nLog: $Global:ErrorLog","NeutraScan Error") | Out-Null } catch {}
    Write-Host $msg -ForegroundColor Red
    exit 1
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$Global:Themes = [ordered]@{
    "GitHub Dark"   = @{ Bg="#0D1117"; Panel="#161B22"; Sidebar="#010409"; Accent="#58A6FF"; Text="#F0F6FC"; Sub="#8B949E"; Border="#30363D" }
    "Midnight Blue" = @{ Bg="#0A1929"; Panel="#112240"; Sidebar="#061326"; Accent="#4E9FFF"; Text="#E6F1FF"; Sub="#8892B0"; Border="#1E3A5F" }
    "Dracula"       = @{ Bg="#282A36"; Panel="#343746"; Sidebar="#1E1F29"; Accent="#BD93F9"; Text="#F8F8F2"; Sub="#6272A4"; Border="#44475A" }
    "Nord"          = @{ Bg="#2E3440"; Panel="#3B4252"; Sidebar="#242933"; Accent="#88C0D0"; Text="#ECEFF4"; Sub="#81A1C1"; Border="#434C5E" }
    "Tokyo Night"   = @{ Bg="#1A1B26"; Panel="#24283B"; Sidebar="#16161E"; Accent="#7AA2F7"; Text="#C0CAF5"; Sub="#565F89"; Border="#414868" }
    "Crimson"       = @{ Bg="#1A0F14"; Panel="#2A1820"; Sidebar="#0F0609"; Accent="#F87171"; Text="#FEE2E2"; Sub="#A16B6B"; Border="#4C1D24" }
    "Emerald"       = @{ Bg="#0A1F14"; Panel="#14301F"; Sidebar="#051208"; Accent="#34D399"; Text="#D1FAE5"; Sub="#6B9A82"; Border="#1E4A32" }
    "Cyber Punk"    = @{ Bg="#0F0B1E"; Panel="#1A1235"; Sidebar="#07040F"; Accent="#FF2E97"; Text="#F0E9FF"; Sub="#9B7BE0"; Border="#3D2861" }
}

$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="NeutraScan - Scan. Identify. Control."
        Height="900" Width="1380"
        MinHeight="720" MinWidth="1120"
        WindowStartupLocation="CenterScreen"
        Background="{DynamicResource BgBrush}"
        FontFamily="Segoe UI"
        UseLayoutRounding="True"
        TextOptions.TextFormattingMode="Display"
        ResizeMode="CanResize">

  <Window.Resources>
    <SolidColorBrush x:Key="BgBrush"      Color="#0D1117"/>
    <SolidColorBrush x:Key="PanelBrush"   Color="#161B22"/>
    <SolidColorBrush x:Key="SidebarBrush" Color="#010409"/>
    <SolidColorBrush x:Key="AccentBrush"  Color="#58A6FF"/>
    <SolidColorBrush x:Key="TextBrush"    Color="#F0F6FC"/>
    <SolidColorBrush x:Key="SubBrush"     Color="#8B949E"/>
    <SolidColorBrush x:Key="BorderBrushX" Color="#30363D"/>
    <SolidColorBrush x:Key="TransBrush"   Color="Transparent"/>
    <SolidColorBrush x:Key="OkBrush"      Color="#3FB950"/>
    <SolidColorBrush x:Key="WarnBrush"    Color="#D29922"/>
    <SolidColorBrush x:Key="ErrBrush"     Color="#F85149"/>
    <SolidColorBrush x:Key="RowBrush"     Color="#0D1117"/>
    <SolidColorBrush x:Key="AltRowBrush"  Color="#161B22"/>

    <Style TargetType="ToolTip">
      <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="HasDropShadow" Value="True"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ToolTip">
            <Border Background="{DynamicResource PanelBrush}"
                    BorderBrush="{DynamicResource AccentBrush}"
                    BorderThickness="0" CornerRadius="5" Padding="11,7">
              <Border.Effect>
                <DropShadowEffect Color="Black" BlurRadius="14" ShadowDepth="3" Opacity="0.55"/>
              </Border.Effect>
              <ContentPresenter/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="Button" x:Key="NavBtn">
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="Foreground" Value="{DynamicResource SubBrush}"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Padding" Value="18,14,18,12"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Grid Background="Transparent">
              <Border x:Name="hover" Background="{DynamicResource PanelBrush}" Opacity="0"/>
              <ContentPresenter Margin="{TemplateBinding Padding}"
                                HorizontalAlignment="Center" VerticalAlignment="Center"/>
              <Border x:Name="underline" Height="2" VerticalAlignment="Bottom"
                      Background="{DynamicResource AccentBrush}" Opacity="0"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="hover" Property="Opacity" Value="0.55"/>
                <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
              </Trigger>
              <Trigger Property="Tag" Value="active">
                <Setter TargetName="underline" Property="Opacity" Value="1"/>
                <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
                <Setter Property="FontWeight" Value="Bold"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="Button" x:Key="ActBtn">
      <Setter Property="Background" Value="#238636"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Padding" Value="20,10"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="5"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Opacity" Value="0.86"/></Trigger>
              <Trigger Property="IsPressed" Value="True"><Setter TargetName="bd" Property="Opacity" Value="0.62"/></Trigger>
              <Trigger Property="IsEnabled" Value="False"><Setter TargetName="bd" Property="Opacity" Value="0.36"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style TargetType="Button" x:Key="RedBtn"    BasedOn="{StaticResource ActBtn}"><Setter Property="Background" Value="#DA3633"/></Style>
    <Style TargetType="Button" x:Key="BlueBtn"   BasedOn="{StaticResource ActBtn}"><Setter Property="Background" Value="#1F6FEB"/></Style>
    <Style TargetType="Button" x:Key="PurpleBtn" BasedOn="{StaticResource ActBtn}"><Setter Property="Background" Value="#8957E5"/></Style>
    <Style TargetType="Button" x:Key="OrangeBtn" BasedOn="{StaticResource ActBtn}"><Setter Property="Background" Value="#D29922"/></Style>

    <Style TargetType="CheckBox">
      <Setter Property="Foreground" Value="{DynamicResource SubBrush}"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="CheckBox">
            <StackPanel Orientation="Horizontal" Background="Transparent">
              <Border x:Name="box" Width="16" Height="16" CornerRadius="3"
                      BorderBrush="{DynamicResource BorderBrushX}" BorderThickness="1.2"
                      Background="{DynamicResource BgBrush}" VerticalAlignment="Center">
                <Path x:Name="check" Data="M 3,8 L 6,11 L 12,4" Stroke="White" StrokeThickness="2"
                      Visibility="Collapsed" HorizontalAlignment="Center" VerticalAlignment="Center"
                      StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round"/>
              </Border>
              <ContentPresenter Margin="8,0,0,0" VerticalAlignment="Center"/>
            </StackPanel>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="box" Property="Background" Value="{DynamicResource AccentBrush}"/>
                <Setter TargetName="box" Property="BorderBrush" Value="{DynamicResource AccentBrush}"/>
                <Setter TargetName="check" Property="Visibility" Value="Visible"/>
                <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="box" Property="BorderBrush" Value="{DynamicResource AccentBrush}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="TextBox">
      <Setter Property="Background" Value="{DynamicResource BgBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
      <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushX}"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="9,7"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="CaretBrush" Value="{DynamicResource AccentBrush}"/>
      <Setter Property="SelectionBrush" Value="{DynamicResource AccentBrush}"/>
    </Style>

    <Style TargetType="ComboBox">
      <Setter Property="Background" Value="{DynamicResource BgBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
      <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushX}"/>
      <Setter Property="Padding" Value="9,6"/>
      <Setter Property="FontSize" Value="12"/>
    </Style>
    <Style TargetType="ComboBoxItem">
      <Setter Property="Background" Value="{DynamicResource BgBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
      <Setter Property="Padding" Value="9,6"/>
    </Style>

    <Style TargetType="TextBlock" x:Key="SectionTitle">
      <Setter Property="Foreground" Value="{DynamicResource AccentBrush}"/>
      <Setter Property="FontSize" Value="10.5"/>
      <Setter Property="FontWeight" Value="Bold"/>
      <Setter Property="Margin" Value="0,0,0,8"/>
    </Style>
    <Style TargetType="TextBlock" x:Key="CardTitle">
      <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
      <Setter Property="FontSize" Value="22"/>
      <Setter Property="FontWeight" Value="Bold"/>
    </Style>
    <Style TargetType="TextBlock" x:Key="CardSub">
      <Setter Property="Foreground" Value="{DynamicResource SubBrush}"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="Margin" Value="0,4,0,20"/>
    </Style>

    <Style TargetType="Border" x:Key="Card">
      <Setter Property="Background" Value="{DynamicResource PanelBrush}"/>
      <Setter Property="CornerRadius" Value="8"/>
      <Setter Property="Padding" Value="18"/>
      <Setter Property="Margin" Value="0,0,0,14"/>
      <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushX}"/>
      <Setter Property="BorderThickness" Value="1"/>
    </Style>

    <Style TargetType="DataGrid">
      <Setter Property="Background" Value="{DynamicResource PanelBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource TextBrush}"/>
      <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushX}"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="RowBackground" Value="{DynamicResource RowBrush}"/>
      <Setter Property="AlternatingRowBackground" Value="{DynamicResource AltRowBrush}"/>
      <Setter Property="GridLinesVisibility" Value="Horizontal"/>
      <Setter Property="HorizontalGridLinesBrush" Value="{DynamicResource BorderBrushX}"/>
      <Setter Property="HeadersVisibility" Value="Column"/>
      <Setter Property="AutoGenerateColumns" Value="False"/>
      <Setter Property="IsReadOnly" Value="True"/>
      <Setter Property="SelectionMode" Value="Single"/>
      <Setter Property="SelectionUnit" Value="FullRow"/>
      <Setter Property="RowHeight" Value="26"/>
      <Setter Property="FontSize" Value="12"/>
    </Style>
    <Style TargetType="DataGridColumnHeader">
      <Setter Property="Background" Value="{DynamicResource SidebarBrush}"/>
      <Setter Property="Foreground" Value="{DynamicResource AccentBrush}"/>
      <Setter Property="FontWeight" Value="Bold"/>
      <Setter Property="FontSize" Value="10.5"/>
      <Setter Property="Padding" Value="9,7"/>
      <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushX}"/>
      <Setter Property="BorderThickness" Value="0,0,1,1"/>
    </Style>
    <Style TargetType="DataGridRow">
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Setter Property="Background" Value="{DynamicResource PanelBrush}"/>
        </Trigger>
        <Trigger Property="IsSelected" Value="True">
          <Setter Property="Background" Value="{DynamicResource BorderBrushX}"/>
        </Trigger>
      </Style.Triggers>
    </Style>
  </Window.Resources>

  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <Border Grid.Row="0" Background="{DynamicResource SidebarBrush}"
            BorderBrush="{DynamicResource BorderBrushX}" BorderThickness="0,0,0,1">
      <Grid Margin="20,14">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>

        <StackPanel Grid.Column="0" Orientation="Horizontal">
          <Border Width="40" Height="40" CornerRadius="10" Background="{DynamicResource AccentBrush}">
            <TextBlock Text="N" Foreground="#FFFFFF" FontSize="22" FontWeight="Bold"
                       HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <StackPanel Margin="13,0,0,0" VerticalAlignment="Center">
            <TextBlock Text="NeutraScan" Foreground="{DynamicResource TextBrush}" FontSize="19" FontWeight="Bold"/>
            <TextBlock Text="Scan. Identify. Control." Foreground="{DynamicResource SubBrush}" FontSize="10.5" FontStyle="Italic"/>
          </StackPanel>
        </StackPanel>

        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
          <TextBlock Text="by littlleprince" Foreground="{DynamicResource SubBrush}" FontSize="11"
                     VerticalAlignment="Center" Margin="0,0,14,0"/>
          <Border Background="{DynamicResource PanelBrush}" CornerRadius="10" Padding="10,4"
                  BorderBrush="{DynamicResource BorderBrushX}" BorderThickness="1">
            <TextBlock Text="v1.0" Foreground="{DynamicResource AccentBrush}" FontSize="10" FontWeight="Bold"/>
          </Border>
        </StackPanel>
      </Grid>
    </Border>

    <Border Grid.Row="1" Background="{DynamicResource SidebarBrush}"
            BorderBrush="{DynamicResource BorderBrushX}" BorderThickness="0,0,0,1">
      <StackPanel Orientation="Horizontal" Margin="14,0">
        <Button x:Name="NavScan"     Style="{StaticResource NavBtn}" Content="NETWORK SCAN"
                ToolTip="Discover hosts, ports, users and operating systems across a subnet."/>
        <Button x:Name="NavIdentity" Style="{StaticResource NavBtn}" Content="IDENTITIES"
                ToolTip="Enumerate logged-in users, local admins, shares and effective privileges on a target."/>
        <Button x:Name="NavMessage"  Style="{StaticResource NavBtn}" Content="MESSAGING"
                ToolTip="Deliver popup messages to remote Windows sessions via msg.exe or WinRM."/>
        <Button x:Name="NavTools"    Style="{StaticResource NavBtn}" Content="TOOLS"
                ToolTip="Ping, traceroute, DNS lookups, port checks, Wake-on-LAN and local network state."/>
        <Button x:Name="NavReports"  Style="{StaticResource NavBtn}" Content="REPORTS"
                ToolTip="Export scan results to CSV, HTML or JSON, and view summary statistics."/>
        <Button x:Name="NavSettings" Style="{StaticResource NavBtn}" Content="SETTINGS"
                ToolTip="Choose a color theme, tune scan timing, and view project information."/>
      </StackPanel>
    </Border>

    <Grid Grid.Row="2" Margin="20,16,20,0">
      <Grid.RowDefinitions>
        <RowDefinition Height="*"/>
        <RowDefinition Height="140"/>
      </Grid.RowDefinitions>

      <Grid Grid.Row="0">

        <ScrollViewer x:Name="PanelScan" VerticalScrollBarVisibility="Auto">
          <StackPanel>
            <TextBlock Text="Network Scan" Style="{StaticResource CardTitle}"/>
            <TextBlock Text="Discover every host on a subnet, fingerprint it, and map its attack surface."
                       Style="{StaticResource CardSub}"/>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="TARGET RANGE" Style="{StaticResource SectionTitle}"/>
                <Grid>
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="220"/>
                    <ColumnDefinition Width="140"/>
                    <ColumnDefinition Width="150"/>
                    <ColumnDefinition Width="*"/>
                  </Grid.ColumnDefinitions>
                  <TextBox x:Name="RangeBox" Grid.Column="0" Text="192.168.1.0/24"
                           ToolTip="CIDR (192.168.1.0/24), range (192.168.1.1-192.168.1.50) or comma list."/>
                  <ComboBox x:Name="ScanModeBox" Grid.Column="1" Margin="8,0,0,0" SelectedIndex="1"
                            ToolTip="Quick = ping + ports. Standard = + OS/user. Deep = + admin check.">
                    <ComboBoxItem>Quick</ComboBoxItem>
                    <ComboBoxItem>Standard</ComboBoxItem>
                    <ComboBoxItem>Deep</ComboBoxItem>
                  </ComboBox>
                  <ComboBox x:Name="PortPresetBox" Grid.Column="2" Margin="8,0,0,0" SelectedIndex="1"
                            ToolTip="Which port list to probe on each live host.">
                    <ComboBoxItem>Top 20</ComboBoxItem>
                    <ComboBoxItem>Top 100</ComboBoxItem>
                    <ComboBoxItem>Common 1-1024</ComboBoxItem>
                    <ComboBoxItem>Full 1-65535</ComboBoxItem>
                  </ComboBox>
                  <StackPanel Grid.Column="3" Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button x:Name="BtnStartScan" Style="{StaticResource ActBtn}" Content="Start Scan"
                            ToolTip="Begin scanning the configured target range."/>
                    <Button x:Name="BtnStopScan"  Style="{StaticResource RedBtn}" Content="Stop"  Margin="8,0,0,0" IsEnabled="False"
                            ToolTip="Abort the running scan."/>
                    <Button x:Name="BtnClear"     Style="{StaticResource BlueBtn}" Content="Clear" Margin="8,0,0,0"
                            ToolTip="Clear results and reset the host counter."/>
                  </StackPanel>
                </Grid>

                <StackPanel Orientation="Horizontal" Margin="0,12,0,0">
                  <CheckBox x:Name="ChkPingOnly" Content="Ping sweep only" ToolTip="Skip port and identity probes."/>
                  <CheckBox x:Name="ChkResolve"  Content="Reverse DNS" IsChecked="True" Margin="18,0,0,0"
                            ToolTip="Attempt PTR lookup for each live host."/>
                  <CheckBox x:Name="ChkMac"      Content="Grab MAC" IsChecked="True" Margin="18,0,0,0"
                            ToolTip="Read MAC address from the local ARP cache."/>
                  <CheckBox x:Name="ChkOs"       Content="Grab OS" IsChecked="True" Margin="18,0,0,0"
                            ToolTip="Query Win32_OperatingSystem via WMI (needs remote access)."/>
                  <CheckBox x:Name="ChkUser"     Content="Grab logged-on user" IsChecked="True" Margin="18,0,0,0"
                            ToolTip="Query Win32_ComputerSystem.UserName via WMI."/>
                </StackPanel>

                <Grid Margin="0,14,0,0">
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                  </Grid.ColumnDefinitions>
                  <ProgressBar x:Name="ScanProgress" Grid.Column="0" Height="8" Minimum="0" Maximum="100" Value="0"/>
                  <TextBlock x:Name="ScanPhase" Grid.Column="1" Text="Idle" Foreground="{DynamicResource SubBrush}"
                             FontSize="11" Margin="12,0,0,0" VerticalAlignment="Center"/>
                </Grid>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}" Padding="0">
              <DataGrid x:Name="ResultsGrid" Height="360" SelectionMode="Single">
                <DataGrid.Columns>
                  <DataGridTextColumn Header="IP"       Binding="{Binding IP}"       Width="130"/>
                  <DataGridTextColumn Header="Hostname" Binding="{Binding Hostname}" Width="180"/>
                  <DataGridTextColumn Header="MAC"      Binding="{Binding MAC}"      Width="140"/>
                  <DataGridTextColumn Header="OS"       Binding="{Binding OS}"       Width="180"/>
                  <DataGridTextColumn Header="User"     Binding="{Binding User}"     Width="160"/>
                  <DataGridTextColumn Header="Ports"    Binding="{Binding Ports}"    Width="*"/>
                  <DataGridTextColumn Header="Admin"    Binding="{Binding Admin}"    Width="90"/>
                </DataGrid.Columns>
              </DataGrid>
            </Border>
          </StackPanel>
        </ScrollViewer>

        <ScrollViewer x:Name="PanelIdentity" VerticalScrollBarVisibility="Auto" Visibility="Collapsed">
          <StackPanel>
            <TextBlock Text="Identity and Privileges" Style="{StaticResource CardTitle}"/>
            <TextBlock Text="Enumerate who is on a host and what they can do." Style="{StaticResource CardSub}"/>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="TARGET" Style="{StaticResource SectionTitle}"/>
                <StackPanel Orientation="Horizontal">
                  <TextBox x:Name="IdentityTarget" Width="220" ToolTip="Hostname or IP of the target machine."/>
                  <Button x:Name="BtnIdUsers"  Style="{StaticResource BlueBtn}"   Content="Logged-in Users" Margin="8,0,0,0"/>
                  <Button x:Name="BtnIdAdmins" Style="{StaticResource PurpleBtn}" Content="Local Admins"     Margin="8,0,0,0"/>
                  <Button x:Name="BtnIdShares" Style="{StaticResource OrangeBtn}" Content="Shares"           Margin="8,0,0,0"/>
                  <Button x:Name="BtnIdPrivs"  Style="{StaticResource RedBtn}"    Content="Privileges"       Margin="8,0,0,0"/>
                  <Button x:Name="BtnIdAll"    Style="{StaticResource ActBtn}"    Content="Run All"          Margin="8,0,0,0"/>
                </StackPanel>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="RESULTS" Style="{StaticResource SectionTitle}"/>
                <TextBox x:Name="IdentityOutput" Height="360" IsReadOnly="True" AcceptsReturn="True"
                         TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"
                         FontFamily="Consolas" FontSize="11" Padding="10"/>
              </StackPanel>
            </Border>
          </StackPanel>
        </ScrollViewer>

        <ScrollViewer x:Name="PanelMessage" VerticalScrollBarVisibility="Auto" Visibility="Collapsed">
          <StackPanel>
            <TextBlock Text="Network Messaging" Style="{StaticResource CardTitle}"/>
            <TextBlock Text="Send popup messages to remote Windows sessions via msg.exe or WinRM." Style="{StaticResource CardSub}"/>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="TARGET" Style="{StaticResource SectionTitle}"/>
                <Grid>
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="240"/>
                    <ColumnDefinition Width="*"/>
                  </Grid.ColumnDefinitions>
                  <TextBox x:Name="MsgTarget" Grid.Column="0" Text="*"
                           ToolTip="Use * for all sessions on the host, or a specific user/session."/>
                  <ComboBox x:Name="MsgDiscovered" Grid.Column="1" Margin="8,0,0,0"/>
                </Grid>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="MESSAGE" Style="{StaticResource SectionTitle}"/>
                <TextBox x:Name="MsgBody" Height="110" AcceptsReturn="True" TextWrapping="Wrap"
                         VerticalScrollBarVisibility="Auto"
                         Text="IT NOTICE: Please save your work. Scheduled maintenance begins in 15 minutes."/>
                <StackPanel Orientation="Horizontal" Margin="0,12,0,0">
                  <Button x:Name="BtnMsgSend"      Style="{StaticResource BlueBtn}" Content="Send to Target"/>
                  <Button x:Name="BtnMsgBroadcast" Style="{StaticResource RedBtn}"  Content="Broadcast to All Discovered" Margin="8,0,0,0"/>
                  <Button x:Name="BtnMsgClear"     Style="{StaticResource ActBtn}"  Content="Clear" Margin="8,0,0,0"/>
                </StackPanel>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="METHOD" Style="{StaticResource SectionTitle}"/>
                <CheckBox x:Name="ChkMsgAuto"  Content="Auto-fallback (msg.exe then WinRM)" IsChecked="True"/>
                <CheckBox x:Name="ChkMsgWinRM" Content="Force WinRM (Invoke-Command)" Margin="0,4,0,0"/>
                <CheckBox x:Name="ChkMsgPopup" Content="Also show a local confirmation popup" IsChecked="True" Margin="0,4,0,0"/>
              </StackPanel>
            </Border>
          </StackPanel>
        </ScrollViewer>

        <ScrollViewer x:Name="PanelTools" VerticalScrollBarVisibility="Auto" Visibility="Collapsed">
          <StackPanel>
            <TextBlock Text="Network Tools" Style="{StaticResource CardTitle}"/>
            <TextBlock Text="Everyday diagnostics in one console." Style="{StaticResource CardSub}"/>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="PING / DNS / TRACEROUTE" Style="{StaticResource SectionTitle}"/>
                <StackPanel Orientation="Horizontal">
                  <TextBox x:Name="ToolHost" Width="240" Text="8.8.8.8"/>
                  <Button x:Name="BtnPing"    Style="{StaticResource BlueBtn}"   Content="Ping"       Margin="8,0,0,0"/>
                  <Button x:Name="BtnTrace"   Style="{StaticResource PurpleBtn}" Content="Traceroute" Margin="8,0,0,0"/>
                  <Button x:Name="BtnDns"     Style="{StaticResource OrangeBtn}" Content="DNS Lookup" Margin="8,0,0,0"/>
                  <Button x:Name="BtnReverse" Style="{StaticResource OrangeBtn}" Content="Reverse DNS" Margin="8,0,0,0"/>
                </StackPanel>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="PORT CHECK" Style="{StaticResource SectionTitle}"/>
                <StackPanel Orientation="Horizontal">
                  <TextBox x:Name="PortHost" Width="200" Text="127.0.0.1"/>
                  <TextBox x:Name="PortList" Width="240" Margin="8,0,0,0" Text="22,80,135,139,443,445,3389"/>
                  <Button x:Name="BtnPortCheck" Style="{StaticResource ActBtn}" Content="Check Ports" Margin="8,0,0,0"/>
                </StackPanel>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="LOCAL SYSTEM" Style="{StaticResource SectionTitle}"/>
                <StackPanel Orientation="Horizontal">
                  <Button x:Name="BtnArp"      Style="{StaticResource BlueBtn}"   Content="ARP Table"/>
                  <Button x:Name="BtnNetstat"  Style="{StaticResource PurpleBtn}" Content="Netstat"     Margin="8,0,0,0"/>
                  <Button x:Name="BtnRoutes"   Style="{StaticResource OrangeBtn}" Content="Route Table" Margin="8,0,0,0"/>
                  <Button x:Name="BtnNeigh"    Style="{StaticResource BlueBtn}"   Content="Neighbors"   Margin="8,0,0,0"/>
                  <Button x:Name="BtnAdapters" Style="{StaticResource ActBtn}"    Content="Adapters"    Margin="8,0,0,0"/>
                  <Button x:Name="BtnIpConfig" Style="{StaticResource ActBtn}"    Content="ipconfig /all" Margin="8,0,0,0"/>
                </StackPanel>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="WAKE-ON-LAN" Style="{StaticResource SectionTitle}"/>
                <StackPanel Orientation="Horizontal">
                  <TextBox x:Name="WolMac"   Width="200" Text="AA:BB:CC:DD:EE:FF"/>
                  <TextBox x:Name="WolBcast" Width="160" Margin="8,0,0,0" Text="255.255.255.255"/>
                  <Button x:Name="BtnWol" Style="{StaticResource PurpleBtn}" Content="Send Magic Packet" Margin="8,0,0,0"/>
                </StackPanel>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="OUTPUT" Style="{StaticResource SectionTitle}"/>
                <TextBox x:Name="ToolsOutput" Height="280" IsReadOnly="True" AcceptsReturn="True"
                         TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"
                         FontFamily="Consolas" FontSize="11" Padding="10"/>
              </StackPanel>
            </Border>
          </StackPanel>
        </ScrollViewer>

        <ScrollViewer x:Name="PanelReports" VerticalScrollBarVisibility="Auto" Visibility="Collapsed">
          <StackPanel>
            <TextBlock Text="Reports and Export" Style="{StaticResource CardTitle}"/>
            <TextBlock Text="Snapshot your scan for the boss." Style="{StaticResource CardSub}"/>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="EXPORT FORMAT" Style="{StaticResource SectionTitle}"/>
                <StackPanel Orientation="Horizontal">
                  <Button x:Name="BtnExportCsv"  Style="{StaticResource ActBtn}"    Content="Export CSV"/>
                  <Button x:Name="BtnExportHtml" Style="{StaticResource BlueBtn}"   Content="Export HTML" Margin="8,0,0,0"/>
                  <Button x:Name="BtnExportJson" Style="{StaticResource PurpleBtn}" Content="Export JSON" Margin="8,0,0,0"/>
                  <Button x:Name="BtnCopyClip"   Style="{StaticResource OrangeBtn}" Content="Copy to Clipboard" Margin="8,0,0,0"/>
                </StackPanel>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="SUMMARY STATS" Style="{StaticResource SectionTitle}"/>
                <TextBox x:Name="StatsOutput" Height="280" IsReadOnly="True" AcceptsReturn="True"
                         TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"
                         FontFamily="Consolas" FontSize="11" Padding="10"/>
                <Button x:Name="BtnRefreshStats" Style="{StaticResource ActBtn}" Content="Refresh Stats"
                        HorizontalAlignment="Left" Margin="0,12,0,0"/>
              </StackPanel>
            </Border>
          </StackPanel>
        </ScrollViewer>

        <ScrollViewer x:Name="PanelSettings" VerticalScrollBarVisibility="Auto" Visibility="Collapsed">
          <StackPanel>
            <TextBlock Text="Settings" Style="{StaticResource CardTitle}"/>
            <TextBlock Text="Theme, timing, about." Style="{StaticResource CardSub}"/>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="THEME" Style="{StaticResource SectionTitle}"/>
                <TextBlock Text="Pick a color scheme. Applies instantly." Foreground="{DynamicResource SubBrush}"
                           FontSize="11" Margin="0,0,0,8"/>
                <ComboBox x:Name="CmbTheme" Width="280" HorizontalAlignment="Left" FontSize="13"/>
                <CheckBox x:Name="ChkSound" Content="Enable UI sound effects" IsChecked="True" Margin="0,14,0,0"/>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="SCAN TUNING" Style="{StaticResource SectionTitle}"/>
                <TextBlock Text="Ping timeout (ms)" Foreground="{DynamicResource SubBrush}" FontSize="11"/>
                <TextBox x:Name="TxtPingTimeout" Width="100" HorizontalAlignment="Left" Text="1200"/>
                <TextBlock Text="Port timeout (ms)" Foreground="{DynamicResource SubBrush}" FontSize="11" Margin="0,8,0,0"/>
                <TextBox x:Name="TxtPortTimeout" Width="100" HorizontalAlignment="Left" Text="250"/>
                <TextBlock Text="Max parallel port connects per host" Foreground="{DynamicResource SubBrush}" FontSize="11" Margin="0,8,0,0"/>
                <TextBox x:Name="TxtPortBatch" Width="100" HorizontalAlignment="Left" Text="64"/>
              </StackPanel>
            </Border>

            <Border Style="{StaticResource Card}">
              <StackPanel>
                <TextBlock Text="ABOUT" Style="{StaticResource SectionTitle}"/>
                <TextBlock Text="NeutraScan v1.0" Foreground="{DynamicResource TextBrush}" FontSize="14" FontWeight="Bold"/>
                <TextBlock Text="by littlleprince" Foreground="{DynamicResource TextBrush}" FontSize="12" FontWeight="SemiBold" Margin="0,2,0,4"/>
                <TextBlock Text="Scan. Identify. Control." Foreground="{DynamicResource AccentBrush}" FontSize="12"
                           FontStyle="Italic" Margin="0,0,0,10"/>
                <TextBlock Text="A no-nonsense corporate network scanner for Windows environments. Runs entirely in PowerShell and WPF."
                           Foreground="{DynamicResource SubBrush}" FontSize="12" TextWrapping="Wrap" Margin="0,0,0,12"/>
                <TextBlock Text="Discord: littlleprince" Foreground="{DynamicResource SubBrush}" FontSize="11"/>
                <TextBlock Text="Email: neutracocontact@gmail.com" Foreground="{DynamicResource SubBrush}" FontSize="11" Margin="0,2,0,0"/>
                <StackPanel Orientation="Horizontal" Margin="0,8,0,0">
                  <TextBlock Text="Website: " Foreground="{DynamicResource SubBrush}" FontSize="11"/>
                  <TextBlock x:Name="SidebarSiteLink" Text="https://neutraco.vercel.app/"
                             Foreground="{DynamicResource AccentBrush}" FontSize="11" Cursor="Hand"/>
                </StackPanel>
              </StackPanel>
            </Border>
          </StackPanel>
        </ScrollViewer>

      </Grid>

      <Border Grid.Row="1" Background="{DynamicResource SidebarBrush}" CornerRadius="8" Margin="0,14,0,0" Padding="14,10"
              BorderBrush="{DynamicResource BorderBrushX}" BorderThickness="1">
        <Grid>
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>
          <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,6">
            <TextBlock Text="ACTIVITY LOG" Foreground="{DynamicResource SubBrush}" FontSize="10" FontWeight="Bold"/>
            <Border Background="{DynamicResource AccentBrush}" Width="22" Height="2" Margin="8,0,0,0"
                    VerticalAlignment="Center" Opacity="0.5"/>
          </StackPanel>
          <TextBox Grid.Row="1" x:Name="LogBox"
                   Background="Transparent" BorderThickness="0"
                   Foreground="{DynamicResource SubBrush}" FontFamily="Consolas" FontSize="11"
                   IsReadOnly="True" TextWrapping="Wrap" AcceptsReturn="True"
                   VerticalScrollBarVisibility="Auto"/>
        </Grid>
      </Border>
    </Grid>

    <Border Grid.Row="3" Background="{DynamicResource SidebarBrush}"
            BorderBrush="{DynamicResource BorderBrushX}" BorderThickness="0,1,0,0" Padding="20,7">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
          <Ellipse x:Name="StatusDot" Width="8" Height="8" Fill="{DynamicResource OkBrush}" VerticalAlignment="Center"/>
          <TextBlock x:Name="StatusText" Text="Ready" Foreground="{DynamicResource OkBrush}"
                     FontSize="11" FontWeight="SemiBold" Margin="7,0,0,0" VerticalAlignment="Center"/>
        </StackPanel>
        <TextBlock x:Name="HostsFound" Grid.Column="1" Text="Hosts found: 0"
                   Foreground="{DynamicResource SubBrush}" FontSize="11" Margin="22,0,0,0" VerticalAlignment="Center"/>
        <TextBlock x:Name="HintText" Grid.Column="2" Text="Hover over controls for details."
                   Foreground="{DynamicResource SubBrush}" FontSize="11" FontStyle="Italic"
                   HorizontalAlignment="Right" VerticalAlignment="Center"/>
      </Grid>
    </Border>
  </Grid>
</Window>
'@

try {
    [xml]$XamlDoc = $XAML
    $XmlReader = New-Object System.Xml.XmlNodeReader $XamlDoc
    $Global:Window = [Windows.Markup.XamlReader]::Load($XmlReader)
} catch {
    throw "XAML failed to load: $($_.Exception.Message)"
}

function N { param([string]$n) return $Global:Window.FindName($n) }

$Global:LogBox         = N 'LogBox'
$Global:StatusText     = N 'StatusText'
$Global:StatusDot      = N 'StatusDot'
$Global:HostsFound     = N 'HostsFound'
$Global:HintText       = N 'HintText'
$Global:ResultsGrid    = N 'ResultsGrid'
$Global:ScanProgress   = N 'ScanProgress'
$Global:ScanPhase      = N 'ScanPhase'
$Global:IdentityOutput = N 'IdentityOutput'
$Global:IdentityTarget = N 'IdentityTarget'
$Global:MsgTarget      = N 'MsgTarget'
$Global:MsgDiscovered  = N 'MsgDiscovered'
$Global:ToolsOutput    = N 'ToolsOutput'
$Global:StatsOutput    = N 'StatsOutput'

$Global:ScanRunning   = $false
$Global:Discovered    = New-Object System.Collections.ArrayList
$Global:FoundIps      = New-Object System.Collections.ArrayList
$Global:ActiveNav     = "NavScan"
$Global:SoundEnabled  = $true
$Global:DefaultHint   = "Hover over controls for details."

function Pump-UI {
    try {
        $frame = New-Object System.Windows.Threading.DispatcherFrame
        $cb = [System.Windows.Threading.DispatcherOperationCallback]{
            param($f)
            $f.Continue = $false
            return $null
        }
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
            [System.Windows.Threading.DispatcherPriority]::Background, $cb, $frame) | Out-Null
        [System.Windows.Threading.Dispatcher]::PushFrame($frame)
    } catch {}
}

function Write-Log {
    param([string]$Msg, [string]$Level = "INFO")
    $t = Get-Date -Format "HH:mm:ss"
    $tag = switch ($Level) {
        "OK"   { "[+]" }
        "WARN" { "[!]" }
        "ERR"  { "[X]" }
        "HEAD" { "===" }
        default { "[-]" }
    }
    try {
        $Global:LogBox.AppendText("$t $tag $Msg`r`n")
        $Global:LogBox.ScrollToEnd()
    } catch {}
    Pump-UI
}

function New-BrushFromHex {
    param([string]$Hex)
    try {
        $c = [Windows.Media.ColorConverter]::ConvertFromString($Hex)
        return [Windows.Media.SolidColorBrush]::new($c)
    } catch { return [Windows.Media.Brushes]::Gray }
}

function Set-Status {
    param([string]$Text, [string]$Color = "#3FB950")
    try {
        $Global:StatusText.Text = $Text
        $br = New-BrushFromHex $Color
        $Global:StatusText.Foreground = $br
        if ($Global:StatusDot) { $Global:StatusDot.Fill = $br }
    } catch {}
    Pump-UI
}

function Set-Phase {
    param([string]$Text)
    try { $Global:ScanPhase.Text = $Text } catch {}
    Pump-UI
}

function Get-Checked {
    param([string]$Name)
    try {
        $el = $Global:Window.FindName($Name)
        if ($el -and $el.IsChecked) { return [bool]$el.IsChecked }
    } catch {}
    return $false
}

function Get-Text {
    param([string]$Name)
    try {
        $el = $Global:Window.FindName($Name)
        if ($el) { return [string]$el.Text }
    } catch {}
    return ""
}

function Invoke-CliCommand {
    param([string]$File, [string[]]$CmdArgs = @(), [int]$TimeoutSec = 45)
    $result = @{ Ok = $false; Output = ""; Error = ""; ExitCode = -1 }
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName               = $File
        $psi.Arguments              = ($CmdArgs -join " ")
        $psi.UseShellExecute        = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.CreateNoWindow         = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $outTask = $proc.StandardOutput.ReadToEndAsync()
        $errTask = $proc.StandardError.ReadToEndAsync()
        $exited = $proc.WaitForExit($TimeoutSec * 1000)
        if (-not $exited) {
            try { $proc.Kill() } catch {}
            $result.Error = "Timed out after ${TimeoutSec}s"
            return $result
        }
        $result.Output   = $outTask.Result
        $result.Error    = $errTask.Result
        $result.ExitCode = $proc.ExitCode
        $result.Ok       = ($proc.ExitCode -eq 0)
        return $result
    } catch {
        $result.Error = $_.Exception.Message
        return $result
    }
}

function Apply-NavColors {
    $active = $Global:ActiveNav
    foreach ($n in @("Scan","Identity","Message","Tools","Reports","Settings")) {
        $btn = $Global:Window.FindName("Nav$n")
        if (-not $btn) { continue }
        if ("Nav$n" -eq $active) { $btn.Tag = "active" } else { $btn.Tag = $null }
    }
}

function Show-Panel {
    param([string]$Name)
    foreach ($n in @("Scan","Identity","Message","Tools","Reports","Settings")) {
        $p = $Global:Window.FindName("Panel$n")
        if ($p) { $p.Visibility = "Collapsed" }
    }
    $target = $Global:Window.FindName("Panel$Name")
    if ($target) { $target.Visibility = "Visible" }
    $Global:ActiveNav = "Nav$Name"
    Apply-NavColors
}

function Set-Theme {
    param([string]$Name)
    if (-not $Global:Themes.Contains($Name)) { return }
    $t   = $Global:Themes[$Name]
    $res = $Global:Window.Resources
    $res["BgBrush"]      = New-BrushFromHex $t.Bg
    $res["PanelBrush"]   = New-BrushFromHex $t.Panel
    $res["SidebarBrush"] = New-BrushFromHex $t.Sidebar
    $res["AccentBrush"]  = New-BrushFromHex $t.Accent
    $res["TextBrush"]    = New-BrushFromHex $t.Text
    $res["SubBrush"]     = New-BrushFromHex $t.Sub
    $res["BorderBrushX"] = New-BrushFromHex $t.Border
    $res["RowBrush"]     = New-BrushFromHex $t.Bg
    $res["AltRowBrush"]  = New-BrushFromHex $t.Panel
    Apply-NavColors
    Write-Log "Theme applied: $Name" "OK"
}

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Convert-IPToInt {
    param([string]$IP)
    $bytes = [System.Net.IPAddress]::Parse($IP).GetAddressBytes()
    $i = ([uint32]$bytes[0] -shl 24) -bor ([uint32]$bytes[1] -shl 16) -bor ([uint32]$bytes[2] -shl 8) -bor [uint32]$bytes[3]
    return [uint32]$i
}

function Convert-IntToIP {
    param([uint32]$Int)
    $b = [byte[]]@(
        [byte](($Int -shr 24) -band 0xFF),
        [byte](($Int -shr 16) -band 0xFF),
        [byte](($Int -shr 8)  -band 0xFF),
        [byte]($Int -band 0xFF)
    )
    return ([System.Net.IPAddress]::new($b)).ToString()
}

function Resolve-Range {
    param([string]$Spec)
    $ips = New-Object System.Collections.ArrayList
    $Spec = $Spec.Trim()

    if ($Spec -match '^(\d+\.\d+\.\d+\.\d+)/(\d+)$') {
        $baseIp = $matches[1]
        $prefix = [int]$matches[2]
        if ($prefix -lt 16) { throw "Prefix too broad (min /16)." }
        $ipInt  = Convert-IPToInt -IP $baseIp
        $mask   = [uint32]([uint32]::MaxValue -shl (32 - $prefix))
        $net    = [uint32]($ipInt -band $mask)
        $bc     = [uint32]($net + [uint32][math]::Pow(2, 32 - $prefix) - 1)
        $count  = [int]($bc - $net - 1)
        if ($count -gt 4094) { throw "Range too large ($count hosts). Limit is 4094." }
        for ($i = $net + 1; $i -lt $bc; $i++) {
            [void]$ips.Add((Convert-IntToIP -Int ([uint32]$i)))
        }
        return ,$ips
    }

    if ($Spec -match '^(\d+\.\d+\.\d+\.)(\d+)-(\d+)$') {
        $pre = $matches[1]; $f = [int]$matches[2]; $t = [int]$matches[3]
        if ($f -gt $t) { $x = $f; $f = $t; $t = $x }
        for ($i = $f; $i -le $t; $i++) { [void]$ips.Add("$pre$i") }
        return ,$ips
    }

    foreach ($part in ($Spec -split ',')) {
        $p = $part.Trim()
        if (-not $p) { continue }
        if ($p -match '^(\d+\.\d+\.\d+\.)(\d+)-(\d+)$') {
            $pre = $matches[1]; $f = [int]$matches[2]; $t = [int]$matches[3]
            if ($f -gt $t) { $x = $f; $f = $t; $t = $x }
            for ($i = $f; $i -le $t; $i++) { [void]$ips.Add("$pre$i") }
        } else {
            [void]$ips.Add($p)
        }
    }
    return ,$ips
}

function Get-PortList {
    param([string]$Preset)
    switch ($Preset) {
        'Top 20'        { return @(21,22,23,25,53,80,110,135,139,143,443,445,993,995,1433,3306,3389,5900,8080,8443) }
        'Top 100'       { return @(21,22,23,25,53,80,110,111,135,137,138,139,143,161,389,443,445,464,514,515,548,554,587,631,636,873,902,989,990,993,995,1025,1080,1194,1241,1311,1337,1433,1521,1701,1723,1755,1812,1883,1900,2000,2049,2082,2083,2100,2222,2375,3000,3128,3268,3269,3306,3389,3690,4000,4369,4444,4848,5000,5060,5222,5357,5432,5555,5601,5672,5900,5985,5986,6000,6379,6443,7001,7077,8000,8008,8080,8081,8088,8443,8888,9000,9001,9042,9090,9092,9100,9200,9300,9418,9443,9999,10000,11211,15672,27017,50000,50070,61616) }
        'Common 1-1024' { return @(1..1024) }
        'Full 1-65535'  { return @(1..65535) }
        default         { return @(21,22,23,25,53,80,110,135,139,143,443,445,3389) }
    }
}

function Invoke-PortScan {
    param([string]$IP, [int[]]$Ports, [int]$TimeoutMs = 250, [int]$BatchSize = 64)
    $open = New-Object System.Collections.ArrayList
    if (-not $Ports -or $Ports.Count -eq 0) { return ,$open }
    $total = $Ports.Count
    for ($i = 0; $i -lt $total; $i += $BatchSize) {
        $end = [Math]::Min($i + $BatchSize - 1, $total - 1)
        $batch = @($Ports[$i..$end])
        $jobs = New-Object System.Collections.ArrayList
        foreach ($port in $batch) {
            try {
                $client = New-Object System.Net.Sockets.TcpClient
                $client.LingerState = New-Object System.Net.Sockets.LingerOption($false, 0)
                $task = $client.BeginConnect($IP, $port, $null, $null)
                [void]$jobs.Add([PSCustomObject]@{ Client = $client; Task = $task; Port = $port })
            } catch {}
        }
        $deadline = (Get-Date).AddMilliseconds($TimeoutMs + 300)
        while ((Get-Date) -lt $deadline) {
            $pending = $false
            foreach ($j in $jobs) { if (-not $j.Task.IsCompleted) { $pending = $true; break } }
            if (-not $pending) { break }
            Pump-UI
            Start-Sleep -Milliseconds 25
        }
        foreach ($j in $jobs) {
            if ($j.Task.IsCompleted) {
                try { $j.Client.EndConnect($j.Task); [void]$open.Add($j.Port) } catch {}
            }
            try { $j.Client.Close() } catch {}
        }
        Pump-UI
    }
    return ,$open
}

function Get-MacFromArp {
    param([string]$IP)
    try {
        $entry = arp -a $IP 2>$null | Select-String ([regex]::Escape($IP))
        if ($entry) {
            $line = $entry.ToString()
            if ($line -match '([0-9a-fA-F]{2}[-:]){5}[0-9a-fA-F]{2}') {
                return $matches[0].ToUpper().Replace('-',':')
            }
        }
    } catch {}
    return ""
}

function Get-RemoteOS {
    param([string]$IP)
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $IP -OperationTimeoutSec 2 -ErrorAction Stop
        return [string]$os.Caption
    } catch { return "" }
}

function Get-RemoteUser {
    param([string]$IP)
    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $IP -OperationTimeoutSec 2 -ErrorAction Stop
        return [string]$cs.UserName
    } catch { return "" }
}

function Get-RemoteHostname {
    param([string]$IP)
    try { return [System.Net.Dns]::GetHostEntry($IP).HostName } catch { return "" }
}

function Add-ResultRow {
    param([string]$IP, [string]$Hostname, [string]$MAC, [string]$OS, [string]$User, [string]$Ports, [string]$Admin)
    $row = [PSCustomObject]@{
        IP       = $IP
        Hostname = $Hostname
        MAC      = $MAC
        OS       = $OS
        User     = $User
        Ports    = $Ports
        Admin    = $Admin
    }
    try { [void]$Global:ResultsGrid.Items.Add($row) } catch {}
    [void]$Global:Discovered.Add($row)
    try { $Global:HostsFound.Text = "Hosts found: $($Global:Discovered.Count)" } catch {}
}

function Invoke-Scan {
    param([string]$RangeSpec, [string]$Mode, [string]$PortPreset,
          [bool]$PingOnly, [bool]$DoResolve, [bool]$DoMac, [bool]$DoOs, [bool]$DoUser)

    $Global:ScanRunning = $true
    try { $Global:Window.FindName("BtnStartScan").IsEnabled = $false } catch {}
    try { $Global:Window.FindName("BtnStopScan").IsEnabled  = $true  } catch {}
    Set-Status "Scanning..." "#D29922"

    try {
        $ips = Resolve-Range -Spec $RangeSpec
    } catch {
        Write-Log "Range parse error: $($_.Exception.Message)" "ERR"
        Set-Status "Idle" "#3FB950"
        $Global:ScanRunning = $false
        try { $Global:Window.FindName("BtnStartScan").IsEnabled = $true } catch {}
        try { $Global:Window.FindName("BtnStopScan").IsEnabled  = $false } catch {}
        return
    }

    $total = $ips.Count
    Write-Log "Scanning $total host(s), mode=$Mode, ports=$PortPreset" "HEAD"
    Set-Phase "Ping sweep ($total hosts)"
    try { $Global:ScanProgress.Value = 0 } catch {}

    $pingTimeout = 1200
    try { $v = [int](Get-Text "TxtPingTimeout"); if ($v -gt 100) { $pingTimeout = $v } } catch {}

    $batchCap = 256
    $idx = 0
    while ($idx -lt $total -and $Global:ScanRunning) {
        $end = [Math]::Min($idx + $batchCap - 1, $total - 1)
        $slice = @($ips[$idx..$end])
        $jobs = New-Object System.Collections.ArrayList
        foreach ($ip in $slice) {
            try {
                $pinger = New-Object System.Net.NetworkInformation.Ping
                $task = $pinger.SendPingAsync($ip, $pingTimeout)
                [void]$jobs.Add([PSCustomObject]@{ IP = $ip; Pinger = $pinger; Task = $task })
            } catch {}
        }
        $deadline = (Get-Date).AddMilliseconds($pingTimeout + 1500)
        while ((Get-Date) -lt $deadline) {
            $pending = $false
            foreach ($j in $jobs) { if (-not $j.Task.IsCompleted) { $pending = $true; break } }
            if (-not $pending) { break }
            if (-not $Global:ScanRunning) { break }
            Pump-UI
            Start-Sleep -Milliseconds 40
        }
        foreach ($j in $jobs) {
            try {
                if ($j.Task.IsCompleted) {
                    $reply = $j.Task.Result
                    if ($reply -and $reply.Status -eq 'Success') { [void]$Global:FoundIps.Add($j.IP) }
                }
            } catch {}
        }
        $idx = $end + 1
        $pct = [Math]::Min(45, ($idx / $total) * 45)
        try { $Global:ScanProgress.Value = $pct } catch {}
        Set-Phase "Ping sweep $idx/$total - $($Global:FoundIps.Count) alive"
        Pump-UI
    }

    Write-Log "Ping sweep done - $($Global:FoundIps.Count) host(s) alive" "OK"

    if (-not $Global:ScanRunning) {
        Write-Log "Scan stopped by user" "WARN"
        Set-Status "Idle" "#3FB950"
        $Global:ScanRunning = $false
        try { $Global:Window.FindName("BtnStartScan").IsEnabled = $true } catch {}
        try { $Global:Window.FindName("BtnStopScan").IsEnabled  = $false } catch {}
        return
    }

    $ports = @()
    if (-not $PingOnly) { $ports = Get-PortList -Preset $PortPreset }
    $portTimeout = 250
    try { $v = [int](Get-Text "TxtPortTimeout"); if ($v -gt 20) { $portTimeout = $v } } catch {}
    $portBatch = 64
    try { $v = [int](Get-Text "TxtPortBatch"); if ($v -gt 0 -and $v -le 512) { $portBatch = $v } } catch {}

    $aliveList = @($Global:FoundIps)
    $n = $aliveList.Count
    $k = 0
    foreach ($ip in $aliveList) {
        if (-not $Global:ScanRunning) { break }
        $k++
        Set-Phase "Fingerprinting $ip ($k/$n)"
        $hostname = ""; $mac = ""; $os = ""; $user = ""; $portStr = ""; $admin = ""

        if ($DoResolve) { $hostname = Get-RemoteHostname -IP $ip }
        if ($DoMac)     { $mac = Get-MacFromArp -IP $ip }
        Pump-UI

        if (-not $PingOnly -and $ports.Count -gt 0) {
            Set-Phase "Port scan $ip ($k/$n)"
            try {
                $open = Invoke-PortScan -IP $ip -Ports $ports -TimeoutMs $portTimeout -BatchSize $portBatch
                if ($open -and $open.Count -gt 0) {
                    $portStr = (($open | Sort-Object) -join ',')
                } else { $portStr = "-" }
            } catch { $portStr = "err" }
        }

        if ($Mode -ne 'Quick') {
            if ($DoOs)   { Set-Phase "OS query $ip";   $os = Get-RemoteOS   -IP $ip }
            if ($DoUser) { Set-Phase "User query $ip"; $user = Get-RemoteUser -IP $ip }
            Pump-UI
        }

        if ($Mode -eq 'Deep') {
            Set-Phase "Admins query $ip"
            try {
                $null = Get-NetLocalGroupMember -ComputerName $ip -GroupName "Administrators" -ErrorAction Stop
                $admin = "Yes"
            } catch { $admin = "Denied" }
            Pump-UI
        }

        Add-ResultRow -IP $ip -Hostname $hostname -MAC $mac -OS $os -User $user -Ports $portStr -Admin $admin
        $pct = 45 + (($k / $n) * 55)
        try { $Global:ScanProgress.Value = $pct } catch {}
        Write-Log "Enriched $ip" "OK"
        Pump-UI
    }

    try { $Global:ScanProgress.Value = 100 } catch {}
    Set-Phase "Idle"
    Set-Status "Scan complete" "#3FB950"
    Write-Log "Scan finished. $($Global:Discovered.Count) host(s) in results." "HEAD"
    Refresh-MsgDropdown
    Refresh-Stats

    $Global:ScanRunning = $false
    try { $Global:Window.FindName("BtnStartScan").IsEnabled = $true } catch {}
    try { $Global:Window.FindName("BtnStopScan").IsEnabled  = $false } catch {}
}

function Write-Identity {
    param([string]$Text)
    try {
        $Global:IdentityOutput.AppendText($Text + "`r`n")
        $Global:IdentityOutput.ScrollToEnd()
    } catch {}
    Pump-UI
}

function Clear-Identity {
    try { $Global:IdentityOutput.Text = "" } catch {}
}

function Get-IdentityUsers {
    param([string]$Target)
    Write-Identity "-- Logged-in users on $Target --"
    try {
        $cs = Get-CimInstance Win32_ComputerSystem -ComputerName $Target -ErrorAction Stop
        if ($cs.UserName) { Write-Identity "  $($cs.UserName)" }
        else { Write-Identity "  (no interactive session)" }
    } catch { Write-Identity "  ERROR: $($_.Exception.Message)" }
    Write-Identity ""
}

function Get-IdentityAdmins {
    param([string]$Target)
    Write-Identity "-- Local Administrators on $Target --"
    try {
        $grp = Get-NetLocalGroupMember -ComputerName $Target -GroupName "Administrators" -ErrorAction Stop
        foreach ($m in $grp) { Write-Identity "  $($m.MemberName)" }
    } catch {
        Write-Identity "  NetLocalGroup failed; trying net.exe..."
        $r = Invoke-CliCommand -File "net.exe" -CmdArgs @("localgroup","Administrators","/domain") -TimeoutSec 20
        if ($r.Output) {
            $r.Output -split "`n" | Where-Object { $_ -match '\S' } | Select-Object -First 40 | ForEach-Object { Write-Identity "  $($_.Trim())" }
        } else { Write-Identity "  ERROR: $($_.Exception.Message)" }
    }
    Write-Identity ""
}

function Get-IdentityShares {
    param([string]$Target)
    Write-Identity "-- Shares on $Target --"
    try {
        $shares = Get-CimInstance Win32_Share -ComputerName $Target -ErrorAction Stop
        foreach ($s in $shares) { Write-Identity "  $($s.Name)  ->  $($s.Path)  [$($s.Type)]" }
    } catch { Write-Identity "  ERROR: $($_.Exception.Message)" }
    Write-Identity ""
}

function Get-IdentityPrivs {
    param([string]$Target)
    Write-Identity "-- Effective privileges on $Target --"
    try {
        $out = Invoke-Command -ComputerName $Target -ScriptBlock { whoami /priv /fo list } -ErrorAction Stop
        foreach ($line in ($out -split "`n")) {
            if ($line -match '\S') { Write-Identity "  $($line.TrimEnd())" }
        }
    } catch {
        Write-Identity "  WinRM unavailable; showing local privileges."
        $out = Invoke-CliCommand -File "whoami.exe" -CmdArgs @("/priv","/fo","list") -TimeoutSec 10
        if ($out.Output) { ($out.Output -split "`n") | Select-Object -First 40 | ForEach-Object { Write-Identity "  $($_.TrimEnd())" } }
    }
    Write-Identity ""
}

function Send-NetworkMessage {
    param([string]$Target, [string]$Body, [bool]$ForceWinRM, [bool]$AutoFallback)
    if (-not $Body -or -not $Body.Trim()) { Write-Log "Empty message" "WARN"; return $false }
    $Body = $Body.Trim()

    if (-not $ForceWinRM) {
        $serverArg = "/server:$Target"
        $r = Invoke-CliCommand -File "msg.exe" -CmdArgs @("*", $serverArg, "`"$Body`"") -TimeoutSec 15
        if ($r.Ok -or ($r.Output -match "sent") -or ($r.Error -eq "")) {
            Write-Log "msg.exe delivered to $Target" "OK"
            return $true
        }
        Write-Log "msg.exe failed for $Target : $($r.Error.Trim())" "WARN"
        if (-not $AutoFallback) { return $false }
    }

    try {
        Invoke-Command -ComputerName $Target -ScriptBlock {
            param($text)
            msg * $text
        } -ArgumentList $Body -ErrorAction Stop | Out-Null
        Write-Log "WinRM delivered to $Target" "OK"
        return $true
    } catch {
        Write-Log "WinRM failed for $Target : $($_.Exception.Message)" "ERR"
        return $false
    }
}

function Refresh-MsgDropdown {
    try {
        $Global:MsgDiscovered.Items.Clear()
        [void]$Global:MsgDiscovered.Items.Add("-- pick a host --")
        foreach ($row in $Global:Discovered) {
            [void]$Global:MsgDiscovered.Items.Add("$($row.IP)  ($($row.Hostname))")
        }
    } catch {}
}

function Write-Tools {
    param([string]$Text)
    try {
        $Global:ToolsOutput.AppendText($Text + "`r`n")
        $Global:ToolsOutput.ScrollToEnd()
    } catch {}
    Pump-UI
}

function Clear-Tools {
    try { $Global:ToolsOutput.Text = "" } catch {}
}

function Refresh-Stats {
    try {
        $stats = ""
        $stats += "Discovered hosts: $($Global:Discovered.Count)`r`n"
        $stats += "Alive IPs:        $($Global:FoundIps.Count)`r`n`r`n"
        $osCounts = @{}
        $portCounts = @{}
        foreach ($r in $Global:Discovered) {
            if ($r.OS) {
                $k = [string]$r.OS
                if (-not $osCounts.ContainsKey($k)) { $osCounts[$k] = 0 }
                $osCounts[$k]++
            }
            if ($r.Ports -and $r.Ports -ne "-" -and $r.Ports -ne "err") {
                foreach ($p in ($r.Ports -split ',')) {
                    $p = $p.Trim()
                    if (-not $portCounts.ContainsKey($p)) { $portCounts[$p] = 0 }
                    $portCounts[$p]++
                }
            }
        }
        if ($osCounts.Count -gt 0) {
            $stats += "OS distribution:`r`n"
            foreach ($k in ($osCounts.Keys | Sort-Object { -$osCounts[$_] })) {
                $stats += "  $k  x$($osCounts[$k])`r`n"
            }
        }
        if ($portCounts.Count -gt 0) {
            $stats += "`r`nTop open ports:`r`n"
            $top = $portCounts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 15
            foreach ($e in $top) { $stats += "  port $($e.Key)  x$($e.Value)`r`n" }
        }
        $Global:StatsOutput.Text = $stats
    } catch { $Global:StatsOutput.Text = "Stats error: $($_.Exception.Message)" }
    Pump-UI
}

function Export-Results {
    param([string]$Format)
    if ($Global:Discovered.Count -eq 0) { Write-Log "No results to export" "WARN"; return }
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    switch ($Format) {
        "csv"  { $dlg.Filter = "CSV|*.csv";   $dlg.FileName = "neutrascan-$(Get-Date -f yyyyMMdd-HHmm).csv" }
        "html" { $dlg.Filter = "HTML|*.html"; $dlg.FileName = "neutrascan-$(Get-Date -f yyyyMMdd-HHmm).html" }
        "json" { $dlg.Filter = "JSON|*.json"; $dlg.FileName = "neutrascan-$(Get-Date -f yyyyMMdd-HHmm).json" }
    }
    if (-not $dlg.ShowDialog()) { return }
    try {
        switch ($Format) {
            "csv"  { $Global:Discovered | Export-Csv -Path $dlg.FileName -NoTypeInformation -Encoding UTF8 }
            "json" { $Global:Discovered | ConvertTo-Json -Depth 4 | Out-File $dlg.FileName -Encoding UTF8 }
            "html" {
                $css = "body{font-family:Segoe UI,sans-serif;background:#0D1117;color:#F0F6FC;margin:0;padding:24px}h1{color:#58A6FF;margin:0 0 4px 0}.sub{color:#8B949E;margin-bottom:24px}table{border-collapse:collapse;width:100%;background:#161B22;border-radius:8px;overflow:hidden}th{background:#010409;color:#58A6FF;text-align:left;padding:10px 12px;font-size:12px;text-transform:uppercase}td{padding:9px 12px;border-top:1px solid #30363D;font-size:13px}tr:hover td{background:#1c2430}.admin-yes{color:#3FB950;font-weight:bold}.admin-no{color:#F85149}"
                $rows = ""
                foreach ($r in $Global:Discovered) {
                    $cls = if ($r.Admin -eq "Yes") { "admin-yes" } else { "admin-no" }
                    $rows += "<tr><td>$($r.IP)</td><td>$($r.Hostname)</td><td>$($r.MAC)</td><td>$($r.OS)</td><td>$($r.User)</td><td>$($r.Ports)</td><td class='$cls'>$($r.Admin)</td></tr>"
                }
                $html = "<!DOCTYPE html><html><head><meta charset='utf-8'><title>NeutraScan Report</title><style>$css</style></head><body><h1>NeutraScan Report</h1><div class='sub'>Generated $(Get-Date) by littlleprince</div><table><thead><tr><th>IP</th><th>Hostname</th><th>MAC</th><th>OS</th><th>User</th><th>Ports</th><th>Admin</th></tr></thead><tbody>$rows</tbody></table></body></html>"
                $html | Out-File $dlg.FileName -Encoding UTF8
            }
        }
        Write-Log "Exported -> $($dlg.FileName)" "OK"
    } catch { Write-Log "Export failed: $($_.Exception.Message)" "ERR" }
}

# =====================================================================
#  SOUND - generated in-memory WAVs, no Windows system sounds
# =====================================================================
function New-ToneWav {
    param(
        [double[]]$Freqs = @(2200),
        [int]$DurationMs = 22,
        [double]$Volume  = 0.14,
        [double]$Decay   = 5.5
    )
    $sampleRate = 44100
    $numSamples = [int]($sampleRate * $DurationMs / 1000)
    $dataSize   = $numSamples * 2
    $ms = New-Object System.IO.MemoryStream
    $bw = New-Object System.IO.BinaryWriter($ms)
    $ascii = [System.Text.Encoding]::ASCII
    $bw.Write([byte[]]$ascii.GetBytes('RIFF'))
    $bw.Write([int](36 + $dataSize))
    $bw.Write([byte[]]$ascii.GetBytes('WAVE'))
    $bw.Write([byte[]]$ascii.GetBytes('fmt '))
    $bw.Write([int]16)
    $bw.Write([int16]1)                    # PCM
    $bw.Write([int16]1)                    # mono
    $bw.Write([int]$sampleRate)
    $bw.Write([int]($sampleRate * 2))      # byte rate
    $bw.Write([int16]2)                    # block align
    $bw.Write([int16]16)                   # bits per sample
    $bw.Write([byte[]]$ascii.GetBytes('data'))
    $bw.Write([int]$dataSize)
    $segLen = [int]($numSamples / [Math]::Max(1, $Freqs.Count))
    for ($i = 0; $i -lt $numSamples; $i++) {
        $seg = [Math]::Min($Freqs.Count - 1, [int]($i / [Math]::Max(1, $segLen)))
        $f   = $Freqs[$seg]
        $t   = $i / $sampleRate
        $env = [Math]::Exp(-1.0 * $Decay * $i / $numSamples)
        $s   = [Math]::Sin(2 * [Math]::PI * $f * $t) * $env * $Volume
        $v   = [int16]([Math]::Max(-32767, [Math]::Min(32767, $s * 32767)))
        $bw.Write($v)
    }
    $bw.Flush()
    $bytes = $ms.ToArray()
    $bw.Close(); $ms.Close()
    return ,$bytes
}

# Pre-render both sounds once at startup
$Global:ClickWav = New-ToneWav -Freqs @(2200)             -DurationMs  22 -Volume 0.14 -Decay 5.5
$Global:ChimeWav = New-ToneWav -Freqs @(1046.5, 1568.0)   -DurationMs 140 -Volume 0.13 -Decay 3.0

function Play-WavBytes {
    param([byte[]]$Bytes)
    if (-not $Global:SoundEnabled -or -not $Bytes) { return }
    try {
        $ms = New-Object System.IO.MemoryStream
        $ms.Write($Bytes, 0, $Bytes.Length)
        $ms.Position = 0
        $sp = New-Object System.Media.SoundPlayer
        $sp.Stream = $ms
        $sp.PlaySync()      # blocks for ~22-140 ms - keeps the stream alive, no GC races
    } catch {}
}

function Play-Click   { Play-WavBytes $Global:ClickWav }
function Play-Success { Play-WavBytes $Global:ChimeWav }

function Attach-Hint {
    param($Element, [string]$Default)
    if (-not $Element) { return }
    $Element.Add_MouseEnter({
        try {
            $tip = $Element.ToolTip
            if ($tip) { $Global:HintText.Text = [string]$tip }
        } catch {}
    })
    $Element.Add_MouseLeave({
        try { $Global:HintText.Text = $Default } catch {}
    })
}

function Install-Hints {
    $root = $Global:Window
    $names = @(
        'NavScan','NavIdentity','NavMessage','NavTools','NavReports','NavSettings',
        'RangeBox','ScanModeBox','PortPresetBox','BtnStartScan','BtnStopScan','BtnClear',
        'ChkPingOnly','ChkResolve','ChkMac','ChkOs','ChkUser',
        'IdentityTarget','BtnIdUsers','BtnIdAdmins','BtnIdShares','BtnIdPrivs','BtnIdAll',
        'MsgTarget','MsgDiscovered','MsgBody','BtnMsgSend','BtnMsgBroadcast','BtnMsgClear',
        'ChkMsgAuto','ChkMsgWinRM','ChkMsgPopup',
        'ToolHost','BtnPing','BtnTrace','BtnDns','BtnReverse',
        'PortHost','PortList','BtnPortCheck',
        'BtnArp','BtnNetstat','BtnRoutes','BtnNeigh','BtnAdapters','BtnIpConfig',
        'WolMac','WolBcast','BtnWol',
        'BtnExportCsv','BtnExportHtml','BtnExportJson','BtnCopyClip','BtnRefreshStats',
        'CmbTheme','ChkSound','TxtPingTimeout','TxtPortTimeout','TxtPortBatch',
        'ResultsGrid','SidebarSiteLink'
    )
    foreach ($name in $names) {
        try {
            $el = $root.FindName($name)
            if ($el) {
                Attach-Hint -Element $el -Default $Global:DefaultHint
                if ($el -is [System.Windows.Controls.Primitives.ButtonBase]) {
                    $el.Add_Click({ Play-Click })
                }
                if ($el -is [System.Windows.Controls.CheckBox]) {
                    $el.Add_Click({ Play-Click })
                }
            }
        } catch {}
    }
}

N 'NavScan'     | ForEach-Object { $_.Add_Click({ Show-Panel "Scan" }) }
N 'NavIdentity' | ForEach-Object { $_.Add_Click({ Show-Panel "Identity" }) }
N 'NavMessage'  | ForEach-Object { $_.Add_Click({ Show-Panel "Message" }) }
N 'NavTools'    | ForEach-Object { $_.Add_Click({ Show-Panel "Tools" }) }
N 'NavReports'  | ForEach-Object { $_.Add_Click({ Show-Panel "Reports" }) }
N 'NavSettings' | ForEach-Object { $_.Add_Click({ Show-Panel "Settings" }) }

N 'BtnStartScan' | ForEach-Object {
    $_.Add_Click({
        try {
            if ($Global:ScanRunning) { return }
            $mode = "Standard"
            try { $mode = [string]((N 'ScanModeBox').SelectedItem).Content } catch {}
            $pp   = "Top 100"
            try { $pp   = [string]((N 'PortPresetBox').SelectedItem).Content } catch {}
            Invoke-Scan `
                -RangeSpec  (Get-Text "RangeBox") `
                -Mode       $mode `
                -PortPreset $pp `
                -PingOnly   (Get-Checked "ChkPingOnly") `
                -DoResolve  (Get-Checked "ChkResolve") `
                -DoMac      (Get-Checked "ChkMac") `
                -DoOs       (Get-Checked "ChkOs") `
                -DoUser     (Get-Checked "ChkUser")
        } catch { Write-Log "Scan crashed: $($_.Exception.Message)" "ERR" }
    })
}

N 'BtnStopScan' | ForEach-Object {
    $_.Add_Click({
        $Global:ScanRunning = $false
        Write-Log "Stop requested" "WARN"
    })
}

N 'BtnClear' | ForEach-Object {
    $_.Add_Click({
        try { $Global:ResultsGrid.Items.Clear() } catch {}
        $Global:Discovered.Clear()
        $Global:FoundIps.Clear()
        try { $Global:HostsFound.Text = "Hosts found: 0" } catch {}
        try { $Global:ScanProgress.Value = 0 } catch {}
        Refresh-MsgDropdown
        Write-Log "Results cleared" "OK"
    })
}

$Global:ResultsGrid.Add_MouseDoubleClick({
    try {
        $row = $Global:ResultsGrid.SelectedItem
        if ($row) {
            $Global:IdentityTarget.Text = $row.IP
            $Global:MsgTarget.Text      = $row.IP
            Write-Log "Target set: $($row.IP)" "OK"
        }
    } catch {}
})

N 'BtnIdUsers'  | ForEach-Object { $_.Add_Click({ Clear-Identity; Get-IdentityUsers  -Target (Get-Text "IdentityTarget") }) }
N 'BtnIdAdmins' | ForEach-Object { $_.Add_Click({ Clear-Identity; Get-IdentityAdmins -Target (Get-Text "IdentityTarget") }) }
N 'BtnIdShares' | ForEach-Object { $_.Add_Click({ Clear-Identity; Get-IdentityShares -Target (Get-Text "IdentityTarget") }) }
N 'BtnIdPrivs'  | ForEach-Object { $_.Add_Click({ Clear-Identity; Get-IdentityPrivs  -Target (Get-Text "IdentityTarget") }) }
N 'BtnIdAll'    | ForEach-Object {
    $_.Add_Click({
        $t = Get-Text "IdentityTarget"
        Clear-Identity
        Get-IdentityUsers  -Target $t
        Get-IdentityAdmins -Target $t
        Get-IdentityShares -Target $t
        Get-IdentityPrivs  -Target $t
    })
}

N 'BtnMsgSend' | ForEach-Object {
    $_.Add_Click({
        $t = Get-Text "MsgTarget"
        if (-not $t) { Write-Log "No target" "WARN"; return }
        $body = Get-Text "MsgBody"
        $forceWinRM = Get-Checked "ChkMsgWinRM"
        $auto = Get-Checked "ChkMsgAuto"
        $popup = Get-Checked "ChkMsgPopup"
        $ok = Send-NetworkMessage -Target $t -Body $body -ForceWinRM $forceWinRM -AutoFallback $auto
        if ($popup) {
            try {
                $m = if ($ok) { "Message sent to $t" } else { "Send failed - check log" }
                [System.Windows.MessageBox]::Show($m, "NeutraScan") | Out-Null
            } catch {}
        }
    })
}

N 'BtnMsgBroadcast' | ForEach-Object {
    $_.Add_Click({
        if ($Global:Discovered.Count -eq 0) { Write-Log "No discovered hosts to broadcast to" "WARN"; return }
        $body = Get-Text "MsgBody"
        $forceWinRM = Get-Checked "ChkMsgWinRM"
        $auto = Get-Checked "ChkMsgAuto"
        $ok = 0; $fail = 0
        foreach ($r in $Global:Discovered) {
            if (Send-NetworkMessage -Target $r.IP -Body $body -ForceWinRM $forceWinRM -AutoFallback $auto) { $ok++ } else { $fail++ }
            Pump-UI
        }
        try { [System.Windows.MessageBox]::Show("Broadcast complete.`nOK: $ok`nFailed: $fail", "NeutraScan") | Out-Null } catch {}
    })
}

N 'BtnMsgClear' | ForEach-Object { $_.Add_Click({ try { (N 'MsgBody').Text = "" } catch {} }) }

$Global:MsgDiscovered.Add_SelectionChanged({
    try {
        $s = [string]$Global:MsgDiscovered.SelectedItem
        if ($s -and $s -notmatch 'pick a host') {
            $Global:MsgTarget.Text = ($s -split '\s+')[0]
        }
    } catch {}
})

N 'BtnPing' | ForEach-Object {
    $_.Add_Click({
        $h = Get-Text "ToolHost"
        if (-not $h) { return }
        Clear-Tools
        Write-Tools "-- Ping $h --"
        try {
            $pinger = New-Object System.Net.NetworkInformation.Ping
            foreach ($i in 1..4) {
                $reply = $pinger.Send($h, 2000)
                if ($reply -and $reply.Status -eq 'Success') {
                    Write-Tools "Reply from $h : time=$($reply.RoundtripTime)ms TTL=$($reply.Options.Ttl)"
                } else {
                    Write-Tools "Request $i : $($reply.Status)"
                }
            }
        } catch { Write-Tools "Error: $($_.Exception.Message)" }
    })
}

N 'BtnTrace' | ForEach-Object {
    $_.Add_Click({
        $h = Get-Text "ToolHost"
        if (-not $h) { return }
        Clear-Tools
        Write-Tools "-- Traceroute to $h --"
        $r = Invoke-CliCommand -File "tracert.exe" -CmdArgs @("-h","15","-w","800",$h) -TimeoutSec 120
        if ($r.Output) { $r.Output -split "`r?`n" | ForEach-Object { if ($_.Trim()) { Write-Tools $_ } } }
        if ($r.Error) { Write-Tools "err: $($r.Error)" }
    })
}

N 'BtnDns' | ForEach-Object {
    $_.Add_Click({
        $h = Get-Text "ToolHost"
        if (-not $h) { return }
        Clear-Tools
        Write-Tools "-- DNS lookup: $h --"
        try {
            $addrs = [System.Net.Dns]::GetHostAddresses($h)
            foreach ($a in $addrs) { Write-Tools "  $($a.IPAddressToString)" }
        } catch { Write-Tools "Error: $($_.Exception.Message)" }
    })
}

N 'BtnReverse' | ForEach-Object {
    $_.Add_Click({
        $h = Get-Text "ToolHost"
        if (-not $h) { return }
        Clear-Tools
        Write-Tools "-- Reverse DNS: $h --"
        try { Write-Tools "  $([System.Net.Dns]::GetHostEntry($h).HostName)" }
        catch { Write-Tools "Error: $($_.Exception.Message)" }
    })
}

N 'BtnPortCheck' | ForEach-Object {
    $_.Add_Click({
        $h = Get-Text "PortHost"
        $list = Get-Text "PortList"
        if (-not $h -or -not $list) { return }
        Clear-Tools
        Write-Tools "-- Port scan $h --"
        $ports = New-Object System.Collections.ArrayList
        foreach ($p in ($list -split ',')) {
            $p = $p.Trim()
            if ($p -match '^(\d+)-(\d+)$') {
                $f = [int]$matches[1]; $t = [int]$matches[2]
                if ($t -ge $f -and ($t - $f) -lt 2000) { foreach ($n in $f..$t) { [void]$ports.Add($n) } }
            } elseif ($p -match '^\d+$') { [void]$ports.Add([int]$p) }
        }
        $open = Invoke-PortScan -IP $h -Ports $ports.ToArray() -TimeoutMs 300 -BatchSize 64
        if ($open.Count -eq 0) { Write-Tools "  (no open ports in $($ports.Count) checked)" }
        else { foreach ($p in ($open | Sort-Object)) { Write-Tools "  OPEN $p" } }
        Write-Tools "  Checked: $($ports.Count) ports, $($open.Count) open"
    })
}

N 'BtnArp' | ForEach-Object {
    $_.Add_Click({
        Clear-Tools; Write-Tools "-- ARP table --"
        $r = Invoke-CliCommand -File "arp.exe" -CmdArgs @("-a") -TimeoutSec 15
        if ($r.Output) { $r.Output -split "`r?`n" | ForEach-Object { if ($_.Trim()) { Write-Tools $_ } } }
    })
}

N 'BtnNetstat' | ForEach-Object {
    $_.Add_Click({
        Clear-Tools; Write-Tools "-- Netstat --"
        $r = Invoke-CliCommand -File "netstat.exe" -CmdArgs @("-an") -TimeoutSec 30
        if ($r.Output) {
            $r.Output -split "`r?`n" | Where-Object { $_ -match 'LISTENING|UDP' } | Select-Object -First 80 | ForEach-Object { Write-Tools $_ }
        }
    })
}

N 'BtnRoutes' | ForEach-Object {
    $_.Add_Click({
        Clear-Tools; Write-Tools "-- Route table --"
        $r = Invoke-CliCommand -File "route.exe" -CmdArgs @("print") -TimeoutSec 15
        if ($r.Output) { $r.Output -split "`r?`n" | ForEach-Object { if ($_.Trim()) { Write-Tools $_ } } }
    })
}

N 'BtnNeigh' | ForEach-Object {
    $_.Add_Click({
        Clear-Tools; Write-Tools "-- Neighbors --"
        try {
            Get-NetNeighbor -ErrorAction Stop | Where-Object { $_.State -ne "Unreachable" } |
                Select-Object -First 60 | ForEach-Object {
                    Write-Tools ("  {0,-16} {1,-20} {2,-10} {3}" -f $_.IPAddress, $_.LinkLayerAddress, $_.State, $_.InterfaceAlias)
                }
        } catch { Write-Tools "Error: $($_.Exception.Message)" }
    })
}

N 'BtnAdapters' | ForEach-Object {
    $_.Add_Click({
        Clear-Tools; Write-Tools "-- Adapters --"
        try {
            Get-NetAdapter -ErrorAction Stop | ForEach-Object {
                Write-Tools ("  {0,-30} {1,-12} {2,-10} {3}" -f $_.Name, $_.Status, $_.LinkSpeed, $_.MacAddress)
            }
        } catch { Write-Tools "Error: $($_.Exception.Message)" }
    })
}

N 'BtnIpConfig' | ForEach-Object {
    $_.Add_Click({
        Clear-Tools; Write-Tools "-- ipconfig /all --"
        $r = Invoke-CliCommand -File "ipconfig.exe" -CmdArgs @("/all") -TimeoutSec 20
        if ($r.Output) { $r.Output -split "`r?`n" | ForEach-Object { if ($_.Trim()) { Write-Tools $_ } } }
    })
}

N 'BtnWol' | ForEach-Object {
    $_.Add_Click({
        $mac = (Get-Text "WolMac").Trim()
        $bc  = (Get-Text "WolBcast").Trim()
        if (-not $mac -or -not $bc) { return }
        Clear-Tools
        Write-Tools "-- Wake-on-LAN --"
        try {
            $macHex = $mac -replace '[:-]',''
            if ($macHex.Length -ne 12) { throw "Invalid MAC (need 12 hex chars)" }
            $macBytes = @()
            for ($i = 0; $i -lt 12; $i += 2) { $macBytes += [Convert]::ToByte($macHex.Substring($i,2),16) }
            $packet = New-Object byte[] (6 + 16*6)
            for ($i = 0; $i -lt 6; $i++) { $packet[$i] = 0xFF }
            for ($r = 1; $r -le 16; $r++) {
                for ($i = 0; $i -lt 6; $i++) { $packet[$r*6 + $i] = $macBytes[$i] }
            }
            $udp = New-Object System.Net.Sockets.UdpClient
            $udp.EnableBroadcast = $true
            $udp.Connect($bc, 9)
            [void]$udp.Send($packet, $packet.Length)
            $udp.Close()
            Write-Tools "  Magic packet sent to $mac via $bc"
            Write-Log "WoL sent to $mac" "OK"
        } catch { Write-Tools "  Error: $($_.Exception.Message)" }
    })
}

N 'BtnExportCsv'  | ForEach-Object { $_.Add_Click({ Export-Results "csv" }) }
N 'BtnExportHtml' | ForEach-Object { $_.Add_Click({ Export-Results "html" }) }
N 'BtnExportJson' | ForEach-Object { $_.Add_Click({ Export-Results "json" }) }
N 'BtnCopyClip'   | ForEach-Object {
    $_.Add_Click({
        try {
            $sb = New-Object System.Text.StringBuilder
            [void]$sb.AppendLine("IP`tHostname`tMAC`tOS`tUser`tPorts`tAdmin")
            foreach ($r in $Global:Discovered) {
                [void]$sb.AppendLine("$($r.IP)`t$($r.Hostname)`t$($r.MAC)`t$($r.OS)`t$($r.User)`t$($r.Ports)`t$($r.Admin)")
            }
            [System.Windows.Clipboard]::SetText($sb.ToString())
            Write-Log "Copied $($Global:Discovered.Count) rows to clipboard" "OK"
        } catch { Write-Log "Copy failed: $($_.Exception.Message)" "ERR" }
    })
}
N 'BtnRefreshStats' | ForEach-Object { $_.Add_Click({ Refresh-Stats }) }

try {
    $sl = N 'SidebarSiteLink'
    if ($sl) {
        $sl.Add_MouseLeftButtonUp({ try { Start-Process "https://neutraco.vercel.app/" } catch {} })
        $sl.ToolTip = "Open https://neutraco.vercel.app/"
    }
} catch {}

N 'ChkSound' | ForEach-Object {
    $_.Add_Click({
        $Global:SoundEnabled = Get-Checked "ChkSound"
        if ($Global:SoundEnabled) { Play-Success }
    })
}

$cmb = N 'CmbTheme'
foreach ($name in $Global:Themes.Keys) { [void]$cmb.Items.Add($name) }
$cmb.Add_SelectionChanged({
    try {
        $sel = (N 'CmbTheme').SelectedItem
        if ($sel) { Set-Theme $sel }
    } catch { Write-Log "Theme change error: $($_.Exception.Message)" "ERR" }
})

Write-Log "NeutraScan v1.0 loaded - Scan. Identify. Control." "HEAD"
Write-Log "by littlleprince - Discord: littlleprince - neutracocontact@gmail.com" "INFO"
Write-Log "Website: https://neutraco.vercel.app/" "INFO"
Write-Log "Tip: Deep mode needs admin rights on targets for full data." "INFO"
Write-Log "Double-click a result row to reuse its IP in Identity/Messaging." "INFO"

Install-Hints

$cmb.SelectedIndex = 0
Show-Panel "Scan"
Refresh-MsgDropdown

[void]$Global:Window.ShowDialog()