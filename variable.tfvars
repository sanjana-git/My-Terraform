# Creds and default location

variable "credentials" { default = "credentials.json" } // Change with you service account .json file

variable "project" { default = "proj-terraform" } // Your GCP Project ID

# Instance Template

variable "prefix" { default = "apache-" }

variable "desc" { default = "This template is used to create Apache server instances." }

variable "tags" { default = "webserver" }

variable "desc_inst" { default = "Apache Web server instance" }

variable "machine_type" { default = "n1-standard-1" }

variable "apache" { default = "apache.sh" }

variable "network" { default = "default" }

#

# Managed Instance Group

variable "rmig_name" { default = "apache-rmig" }

variable "base_instance_name" { default = "apache" }

variable "target_size" { default = "3" }

#

# Healthcheck

variable "hc_name" { default = "apache-healthcheck" }

variable "hc_port" { default = "80" }

#

# Backend

variable "be_name" { default = "http-backend" }

variable "be_protocol" { default = "HTTP" }

variable "be_port_name" { default = "http" }

variable "be_timeout" { default = "10" }

variable "be_session_affinity" { default = "NONE" }

#

# RMIG Autoscaler

variable "rmig_as_name" { default = "rmig-as" }

#

# Global Forwarding Rule

variable "gfr_name" { default = "website-forwarding-rule" }

variable "gfr_portrange" { default = "80" }

variable "thp_name" { default = "http-proxy" }

variable "urlmap_name" { default = "http-lb-url-map" }

# Firewall Rules

variable "fwr_name" { default = "allow-http-https" }
