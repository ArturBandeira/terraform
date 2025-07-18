variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS CLI profile (SSO)"
  type        = string
  default     = "Developer2-765732380112"   # o nome do seu profile SSO
}

# Tags Obrigatórias da empresa
variable "ambiente" {
  description = "Ambiente ao qual o recurso pertence"
  type        = string
  default     = "LAB"
}

variable "responsavel" {
  description = "Email do responsável pelo recurso"
  type        = string
  default     = "artur.jorge@inmetrics.com.br"
}

variable "centrodecusto" {
  description = "ID ou sigla do projeto / centro de custo"
  type        = string
  default     = "1"  # ou outra sigla válida
}

variable "schedule" {
  description = "Tag de agendamento de uso das instâncias (shutdown|everydayhours|officehours|weekendshours|online)"
  type        = string
  default     = "shutdown"
}

# EC2 Application Instance Type
variable "app_instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.micro"
}

# RDS Database settings
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage (GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}

variable "owner_tag" {
  description = "Identifier for resource owner"
  type        = string
  default     = "Developer2_84263f1c06dd171d"
}
