resource "openstack_compute_instance_v2" "controller" {
    name = "${var.cluster_name}-controller-${count.index}"
    count = "1"
    image_name = "${var.kubernetes_image_name}"
    flavor_id = "${var.kubernetes_flavor_id}"
    key_pair = "k8s"
    network {
        uuid = "c8f3016f-c451-4aaa-915b-6704d2a6a97e"
    }
    security_groups = [
        "default",
        "k8s"
    ]
    connection {
       user = "ubuntu"
       private_key = "file("/home/ubuntu/.ssh/k8s.pem")" 
    }
    provisioner "file" {
        source = "files"
        destination = "/tmp/stage"
    }
    provisioner "remote-exec" {
        inline = [
          "sudo bash /tmp/stage/set_hosts.sh",
          "echo '----> Starting Kubernetes Controller with'",
          "echo sudo kubeadm init --token ${var.kubernetes_token} --apiserver-advertise-address ${openstack_compute_instance_v2.controller.0.network.0.fixed_ip_v4}",
          "sudo kubeadm init --token ${var.kubernetes_token} --apiserver-advertise-address ${openstack_compute_instance_v2.controller.0.network.0.fixed_ip_v4}",
          "sudo rm -rf /tmp/stage"
        ]
    }
}


resource "openstack_compute_instance_v2" "compute" {
    name = "${var.cluster_name}-compute${count.index}"
    count = "${var.compute_count}"
    image_name = "${var.kubernetes_image_name}"
    flavor_id = "${var.kubernetes_flavor_id}"
    key_pair = "k8s"
    network {
        uuid = "c8f3016f-c451-4aaa-915b-6704d2a6a97e"
    }
    security_groups = [
        "default",
        "k8s"
    ]
    connection {
       user = "ubuntu"
       private_key = "file("/home/ubuntu/.ssh/k8s.pem")" 
    }
    provisioner "file" {
        source = "files"
        destination = "/tmp/stage"
    }
    provisioner "remote-exec" {
        inline = [
          "sudo bash /tmp/stage/set_hosts.sh",
          "echo '----> Joining K8s Controller with'",
          "echo sudo kubeadm join --token ${var.kubernetes_token} --discovery-token-unsafe-skip-ca-verification ${openstack_compute_instance_v2.controller.0.network.0.fixed_ip_v4}:6443"
          "sudo kubeadm join --token ${var.kubernetes_token} --discovery-token-unsafe-skip-ca-verification ${openstack_compute_instance_v2.controller.0.network.0.fixed_ip_v4}:6443",
          "sudo rm -rf /tmp/stage"
        ]
    }
    depends_on = [
        "openstack_compute_instance_v2.controller"
    ]
}

