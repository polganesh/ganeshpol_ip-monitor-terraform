
resource "aws_route53_record" "main" {
	zone_id = "${var.primaryzone_id}"
	name    = "${var.record_name}"
	type    = "${var.record_type}"
	ttl     = "${var.ttl}"
	records = ["${var.records}"]
    set_identifier = "${var.set_identifier}"

	weighted_routing_policy {
		weight = "${var.weight}"
	}
}