# Implementation walkthrough

A browser-based operations platform needed reachable sign-in and application pages while its database and employee documents required tighter network and identity boundaries. Deployment and recovery callers also needed a documented route.

## 1. Inventory callers

List the application runtime, hosted runner, operator, managed connector and recovery host. A private IP by itself does not give those callers a route or identity.

## 2. Read the Terraform foundation

Hub and spoke address ranges are fictional and must not overlap. Peering is reciprocal; it is not transitive routing. The application subnet delegation follows the Functions Flex integration pattern.

## 3. Test the DNS boundary

The model requires both a linked private zone and an endpoint before returning the private address. In Azure, test the actual hostname from every caller; endpoint creation can also change public CNAME behavior.

## 4. Plan the cutover

Keep the optional endpoint off until the exact existing target, group ID, DNS zone, route and caller matrix are reviewed. Review an entire saved Terraform plan before applying it; this repository performs no apply.

## Read the implementation

Start with [the domain module](../lab/domain.py), then [its tests](../tests/test_domain.py). The [dashboard report](../lab/demo.py) runs the same implementation; it does not substitute static success labels. `python -B -m lab demo` exits with an error if a demonstration assertion fails.

## Discuss the result

Describe the business problem first, the trust boundary second and the observed result third. Claim only the evidence in the validation record. A portable reference test is useful evidence of code behavior; it is not live-provider acceptance.
