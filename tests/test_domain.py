import unittest
from lab.domain import validate, resolve, allowed


class NetworkTests(unittest.TestCase):
    def topology(self):
        return {
            "hub": "10.20.0.0/16",
            "spoke": "10.40.0.0/16",
            "subnets": {"functions": "10.40.1.0/24", "endpoints": "10.40.2.0/24"},
        }

    def test_disjoint(self):
        self.assertTrue(validate(self.topology()))

    def test_overlap(self):
        t = self.topology()
        t["hub"] = t["spoke"]
        with self.assertRaises(ValueError):
            validate(t)

    def test_subnet_outside(self):
        t = self.topology()
        t["subnets"]["functions"] = "10.90.1.0/24"
        with self.assertRaises(ValueError):
            validate(t)

    def test_subnet_overlap(self):
        t = self.topology()
        t["subnets"]["endpoints"] = t["subnets"]["functions"]
        with self.assertRaises(ValueError):
            validate(t)

    def test_dns_both_required(self):
        for linked, endpoint in [(False, False), (False, True), (True, False)]:
            self.assertEqual(
                resolve("documents.example.invalid", linked, endpoint), "203.0.113.10"
            )

    def test_private_dns(self):
        self.assertEqual(resolve("documents.example.invalid", True, True), "10.40.2.10")

    def test_https_allowed(self):
        self.assertTrue(allowed("10.40.1.5", "10.40.2.10", 443))

    def test_other_spoke_denied(self):
        self.assertFalse(allowed("10.90.1.5", "10.40.2.10", 443))

    def test_ssh_denied(self):
        self.assertFalse(allowed("10.40.1.5", "10.40.2.10", 22))

    def test_public_denied(self):
        self.assertFalse(allowed("198.51.100.20", "203.0.113.10", 443))
