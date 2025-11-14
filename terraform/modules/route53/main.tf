# Route53 Module - Main Configuration

# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-hosted-zone"
    }
  )
}

# Output nameservers for manual delegation
output "nameservers_info" {
  value = <<-EOT
  
  ========================================
  DNS DELEGATION REQUIRED
  ========================================
  
  Your Route53 hosted zone has been created for: ${var.domain_name}
  
  To make your domain work with this platform, you need to update your domain registrar
  with the following nameservers:
  
  ${join("\n  ", aws_route53_zone.main.name_servers)}
  
  Steps:
  1. Log into your domain registrar (GoDaddy, Namecheap, Google Domains, etc.)
  2. Find the DNS or Nameserver settings for ${var.domain_name}
  3. Replace the existing nameservers with the 4 nameservers listed above
  4. Save the changes
  5. Wait for DNS propagation (usually 5-30 minutes, can take up to 48 hours)
  
  You can verify delegation is working by running:
    dig NS ${var.domain_name}
  
  ========================================
  EOT
}
