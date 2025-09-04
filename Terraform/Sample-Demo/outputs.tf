output "instance_id" {
  value       = aws_instance.web.id
  description = "The EC2 instance ID"
}

output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP address of the instance"
}

output "public_dns" {
  value       = aws_instance.web.public_dns
  description = "Public DNS of the instance"
}

output "web_url" {
  value       = var.allow_http && aws_instance.web.public_ip != "" ? "http://${aws_instance.web.public_ip}/" : ""
  description = "HTTP URL (if HTTP allowed)"
}