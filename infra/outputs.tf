output "instance_names" {
  description = "起動したVMインスタンス名の一覧"
  value       = [for vm in google_compute_instance.vm_instance : vm.name]
}

output "instance_external_ips" {
  description = "起動したVMインスタンスの外部IPの一覧"
  value       = { for k, vm in google_compute_instance.vm_instance : k => vm.network_interface[0].access_config[0].nat_ip }
}
