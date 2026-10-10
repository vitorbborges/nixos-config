{ ... }:

{
  boot.kernel.sysctl = {
    "dev.tty.ldisc_autoload" = 0;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = 0;
    "kernel.io_uring_disabled" = 2;
    "kernel.kexec_load_disabled" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.oops_limit" = 100;
    "kernel.warn_limit" = 100;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };

  boot.kernelParams = [
    "efi=disable_early_pci_dma"
    "init_on_free=1"
    "iommu.strict=1"
    "page_alloc.shuffle=1"
    "slab_nomerge"
    "vsyscall=none"
  ];
}
