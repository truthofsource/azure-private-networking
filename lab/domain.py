"""Configuration checks and an explicit network-policy model; not a cloud probe."""

import ipaddress


def validate(topology):
    hub = ipaddress.ip_network(topology["hub"])
    spoke = ipaddress.ip_network(topology["spoke"])
    if hub.version != 4 or spoke.version != 4 or hub.overlaps(spoke):
        raise ValueError("Hub and spoke must be distinct IPv4 networks")
    subnets = [ipaddress.ip_network(x) for x in topology["subnets"].values()]
    if any(not s.subnet_of(spoke) for s in subnets):
        raise ValueError("A subnet escapes its spoke")
    if any(a.overlaps(b) for i, a in enumerate(subnets) for b in subnets[i + 1 :]):
        raise ValueError("Subnets overlap")
    return True


def resolve(name, zone_linked, private_endpoint):
    if name != "documents.example.invalid":
        raise ValueError("Only the fictional lab service is modeled")
    return "10.40.2.10" if zone_linked and private_endpoint else "203.0.113.10"


def allowed(source, destination, port, public_access=False):
    source = ipaddress.ip_address(source)
    destination = ipaddress.ip_address(destination)
    if source.version != 4 or destination.version != 4:
        return False
    if destination == ipaddress.ip_address("203.0.113.10"):
        return public_access and port == 443
    return (
        source in ipaddress.ip_network("10.40.1.0/24")
        and destination == ipaddress.ip_address("10.40.2.10")
        and port == 443
    )


def demo():
    config = {
        "hub": "10.20.0.0/16",
        "spoke": "10.40.0.0/16",
        "subnets": {"application": "10.40.1.0/24", "endpoints": "10.40.2.0/24"},
    }
    checks = [
        {
            "name": "Address plan is disjoint and subnets are contained",
            "passed": validate(config),
            "detail": "Actual ipaddress validation of the example plan",
        },
        {
            "name": "Linked zone selects the private endpoint",
            "passed": resolve("documents.example.invalid", True, True) == "10.40.2.10",
            "detail": "Policy-model result, not a live DNS lookup",
        },
        {
            "name": "Application HTTPS to private storage is permitted",
            "passed": allowed("10.40.1.20", "10.40.2.10", 443),
            "detail": "Source subnet, destination and port all match",
        },
        {
            "name": "Internet client cannot reach the private document path",
            "passed": not allowed("198.51.100.20", "10.40.2.10", 443),
            "detail": "Expected deny in the model",
        },
        {
            "name": "Public resolution does not grant public data access",
            "passed": not allowed(
                "10.40.1.20", resolve("documents.example.invalid", False, True), 443
            ),
            "detail": "DNS, routing and service authorization are separate",
        },
        {
            "name": "SSH is not authorized by the HTTPS rule",
            "passed": not allowed("10.40.1.20", "10.40.2.10", 22),
            "detail": "Expected deny in the model",
        },
    ]
    return {
        "checks": checks,
        "metrics": [
            {
                "label": "Virtual networks",
                "value": "2",
                "detail": "Hub and application spoke",
            },
            {
                "label": "Workload subnets",
                "value": "2",
                "detail": "Application and endpoints",
            },
            {
                "label": "Open inbound SSH",
                "value": "0",
                "detail": "No management ingress in the example",
            },
            {
                "label": "Live network changes",
                "value": "0",
                "detail": "Model and source validation only",
            },
        ],
        "records": [
            ["hub", "10.20.0.0/16", "Shared connectivity boundary"],
            ["spoke", "10.40.0.0/16", "Application ownership boundary"],
            [
                "documents.example.invalid",
                resolve("documents.example.invalid", True, True),
                "Fictional service / illustrative address",
            ],
            [
                "external-client",
                "Denied",
                "Private service path is not a public website route",
            ],
        ],
    }
