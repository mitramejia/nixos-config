# Troubleshooting Notes

## 2026-06-25: MediaTek MT7922 Wi-Fi throughput and jitter

### Symptom

The NixOS desktop was getting roughly 70-100 Mbps download over Wi-Fi while nearby Apple devices reached about 400+ Mbps on the same internet plan. The plan is 500 Mbps download and 250 Mbps upload.

### Hardware and runtime facts

- Wi-Fi adapter: MediaTek MT7922 802.11ax PCIe, PCI ID `14c3:0616`.
- Linux driver: `mt7921e`.
- Kernel during testing: `7.0.10`.
- Ethernet adapter: Realtek 2.5GbE on `enp14s0`.
- Router gateway: `10.0.0.1`.
- Primary Wi-Fi interface: `wlp15s0`.

### What we tested

- The PC initially selected the 2.4 GHz BSSID for `Mitransaccion`.
  - Frequency: `2412 MHz`.
  - Real download was about 58-70 Mbps.
  - This explained the first bad result.
- Moving to the 5 GHz SSID improved link rate, but real throughput remained poor.
  - Frequency: `5240 MHz`, channel `48`.
  - Signal improved to around `-60` to `-63 dBm`.
  - PHY rates sometimes reached `720-960 Mbps`.
  - Despite that, gateway ping still spiked above 100 ms.
- WPA3/AES and a fixed 5 GHz channel improved association quality but did not fix throughput.
- NetworkManager Wi-Fi power save was disabled and confirmed with `iw`.
  - `Power save: off`.
  - This did not fix the issue; jitter and retries remained.
- Ethernet immediately removed local jitter.
  - Gateway ping over Ethernet: about `0.5 ms` average with almost no variance.
  - Parallel download over Ethernet reached about `486 Mbps`.
  - Ethernet link negotiated at `1000Mb/s`.
- A nearby M5 Max MacBook reached about `400 Mbps` download on Wi-Fi, confirming the router and ISP can deliver high Wi-Fi throughput.

### Key evidence

The bad Wi-Fi behavior is local to the NixOS PC's Wi-Fi path:

```text
wlp15s0 Wi-Fi gateway ping:
avg 38-72 ms
max 146-218 ms
packet loss 0%

enp14s0 Ethernet gateway ping:
avg 0.501 ms
max 0.605 ms
packet loss 0%
```

The `mt7921e` station counters showed heavy retransmission:

```text
tx packets: 260501
tx retries: 131401
tx failed: 840
```

After reconnecting with Wi-Fi power save disabled, retries were still high:

```text
tx packets: 7739
tx retries: 2305
tx failed: 0
```

### Current conclusion

The ISP and router WAN path are not the main problem. Ethernet reached near-plan download speed, and the MacBook gets high Wi-Fi download next to the PC.

The remaining problem is likely one of:

- MediaTek MT7922 / `mt7921e` Linux driver behavior.
- MT7922 firmware/AP compatibility.
- Desktop motherboard antenna path or placement.
- 160 MHz / channel behavior with this specific client.

### Online findings

Reports for MT7922 / `mt7921e` commonly mention slow Wi-Fi, high latency, 5 GHz instability, and power-management sensitivity.

Relevant findings:

- Linux Wireless documents MT7922 as supported by the `mt76` / `mt7921e` stack.
- Fedora users report MT7922 download degradation where module reload or Wi-Fi power-save changes can temporarily help.
- Pop!_OS users report MT7922 5 GHz trouble and handshake timeouts across some kernel versions.
- ArchWiki and Arch forum discussions point at high latency on MT7921/MT7922 and suggest testing `mt7921e.disable_aspm=1`.

The local kernel exposes the ASPM parameter, and it is currently disabled:

```text
parm: disable_aspm:disable PCI ASPM support (bool)
/sys/module/mt7921e/parameters/disable_aspm=N
```

### Current test configured

ASPM disable is configured in `modules/core/boot.nix` for the MT7922 driver:

```nix
boot.extraModprobeConfig = ''
  options mt7921e disable_aspm=1
'';
```

After switching and rebooting, verify:

```sh
cat /sys/module/mt7921e/parameters/disable_aspm
ping -I wlp15s0 -c 30 -i 0.2 10.0.0.1
nix shell nixpkgs#iw -c iw dev wlp15s0 station dump | sed -n '1,40p'
```

Expected improvement if ASPM is the cause:

- `disable_aspm` reads `Y`.
- Gateway ping becomes stable and much closer to low single-digit milliseconds.
- `tx retries` grows much more slowly relative to `tx packets`.
- Download speed moves closer to the MacBook's Wi-Fi result.

If this does not materially reduce jitter and retries, stop spending much more time on software tuning. Use Ethernet or replace the MediaTek card with better-supported Wi-Fi hardware, such as an Intel AX210-class adapter.
