######################################################################
### OUTPUTS

output "ELBs" {
  description = "Map of ELB resource objects."
  value       = aws_lb.map
}

output "ELB_Listeners" {
  description = "Map of ELB Listener resource objects."
  value       = aws_lb_listener.map
}

output "ELB_Listener_Rules" {
  description = "Map of ELB Listener Rule resource objects (does not include default listener actions)."
  value       = aws_lb_listener_rule.map
}

output "ELB_Target_Groups" {
  description = "Map of ELB Target Group resource objects."
  value       = aws_lb_target_group.map
}

output "ELB_Target_Group_Attachments" {
  description = "Map of ELB Target Group Attachment resource objects."
  value       = aws_lb_target_group_attachment.map
}

######################################################################
