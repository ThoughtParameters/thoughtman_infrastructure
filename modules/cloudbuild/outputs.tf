# ./modules/cloudbuild/outputs.tf

output "trigger_id" {
  description = "The ID of the created Cloud Build trigger."
  value       = google_cloudbuild_trigger.service_trigger.id
}

output "cloudbuild_service_account_email" {
  description = "The email of the default Cloud Build service account."
  value       = data.google_project_service_identity.cloudbuild_sa.email
}
