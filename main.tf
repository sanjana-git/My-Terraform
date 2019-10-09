# Credentials

provider "google" {

credentials = "${var.credentials}"

project = "${var.project}"

region = "${var.region}"

}

#

# Backend Services

resource "google_compute_backend_service" "rbs" {

name = "${var.be_name}"

port_name = "${var.be_port_name}"

protocol = "${var.be_protocol}"

timeout_sec = "${var.be_timeout}"

session_affinity = "${var.be_session_affinity}"

backend {

group = "${google_compute_region_instance_group_manager.rmig1.instance_group}"

}

backend {

group = "${google_compute_region_instance_group_manager.rmig2.instance_group}"

}

backend {

group = "${google_compute_region_instance_group_manager.rmig3.instance_group}"

}

health_checks = ["${google_compute_http_health_check.default.self_link}"]

}

resource "google_compute_http_health_check" "default" {

name = "${var.hc_name}"

request_path = "/"

check_interval_sec = 1

timeout_sec = 1

}#

# Regional MIG 1

resource "google_compute_region_instance_group_manager" "rmig1" {

name = "rmig1"

instance_template = "${google_compute_instance_template.cit.self_link}"

base_instance_name = "${var.base_instance_name}"

region = "us-central1"

target_size = 3

named_port {

name = "http"

port = 80

}

}

#Regional MIG2

resource "google_compute_region_instance_group_manager" "rmig2" {

name = "rmig2"

instance_template = "${google_compute_instance_template.cit.self_link}"

base_instance_name = "${var.base_instance_name}"

region = "us-east1"

target_size = 3

named_port {

name = "http"

port = 80

}

}

#Regional MIG3

resource "google_compute_region_instance_group_manager" "rmig3" {

name = "rmig3"

instance_template = "${google_compute_instance_template.cit.self_link}"

base_instance_name = "${var.base_instance_name}"

region = "us-west1"

target_size = 3

named_port {

name = "http"

port = 80

}

}

# Template creation

resource "google_compute_instance_template" "cit" {

name_prefix = "${var.prefix}"

description = "${var.desc}"

project = "${var.project}"

tags = ["${var.tags}"]

instance_description = "${var.desc_inst}"

machine_type = "${var.machine_type}"

can_ip_forward = false // Whether to allow sending and receiving of packets with non-matching source or destination IPs. This defaults to false.

scheduling {

automatic_restart = true

on_host_maintenance = "MIGRATE"

}

// Create a new boot disk from an image

disk {

source_image = "debian-cloud/debian-9"

auto_delete = true

boot = true

}

metadata = {

startup-script = <<SCRIPT

sudo apt-get -y update

sudo apt-get -y install apache2

sudo service apache start

sudo apt-get -y install curl

SCRIPT

}

network_interface {

network = "${var.network}"

}

}

service_account {

scopes = ["userinfo-email", "compute-ro", "storage-ro"]

}

lifecycle {

create_before_destroy = true

}

}

#

# Compute Healthcheck

resource "google_compute_health_check" "default" {

name = "${var.hc_name}"

check_interval_sec = 1

timeout_sec = 1

tcp_health_check {

port = "${var.hc_port}"

}

}

#

# Regional MIG1 AutoScaler

resource "google_compute_region_autoscaler" "cras1" {

name = "${var.rmig_as_name}"

region = "us-central1"

target = "${google_compute_region_instance_group_manager.rmig1.self_link}"

autoscaling_policy {

max_replicas = 5

min_replicas = 1

cooldown_period = 60

cpu_utilization {

target = 0.5

}

}

}# Regional MIG2 AutoScaler

resource "google_compute_region_autoscaler" "cras2" {

name = "cras2"

region = "us-east1"

target = "${google_compute_region_instance_group_manager.rmig2.self_link}"

autoscaling_policy {

max_replicas = 5

min_replicas = 1

cooldown_period = 60

cpu_utilization {

target = 0.5

}

}

}

# Regional MIG3 AutoScaler

resource "google_compute_region_autoscaler" "cras3" {

name = "cras3"

region = "us-west1"

target = "${google_compute_region_instance_group_manager.rmig3.self_link}"

autoscaling_policy {

max_replicas = 5

min_replicas = 1

cooldown_period = 60

cpu_utilization {

target = 0.5

}

}

}

#

# Global Forwarding Rule

resource "google_compute_global_forwarding_rule" "gfr" {

name = "${var.gfr_name}"

target = "${google_compute_target_http_proxy.thp.self_link}"

port_range = "${var.gfr_portrange}"

}

resource "google_compute_target_http_proxy" "thp" {

name = "${var.thp_name}"

url_map = "${google_compute_url_map.urlmap.self_link}"

}

resource "google_compute_url_map" "urlmap" {

name = "${var.urlmap_name}"

default_service = "${google_compute_backend_service.rbs.self_link}"

}

#

# Firewall rules for specific Tags

resource "google_compute_firewall" "default" {

name = "${var.network}-${var.fwr_name}"

network = "${var.network}"

project = "${var.project}"

allow {

protocol = "tcp"

ports = ["80"]

}

}
