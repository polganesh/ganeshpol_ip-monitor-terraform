variable "primaryzone_id"{}

variable "record_name"{}

variable "record_type"{
	description="Possible values A, AAAA,CNAME,CAA,MX,NAPTR,NS,PTR,SOA,SPF,SRV,TXT"
}

variable "ttl"{
	description="Time to live. default for production 172800 seconds i.e. 2 days. we can reduce to less like 10 seconds for test environment."
	default="172800"
}

variable "records"{
	type="list"
}













