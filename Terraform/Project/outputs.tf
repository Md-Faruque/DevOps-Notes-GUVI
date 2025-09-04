output "website_url" {
  description = "Public URL of the website"
  value       = "http://${aws_eip.devopschallenge_eip.public_ip}"
}

output "public_ip" {
  description = "Elastic IP attached to the EC2 instance"
  value       = aws_eip.devopschallenge_eip.public_ip
}
