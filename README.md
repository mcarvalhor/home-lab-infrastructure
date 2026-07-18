# home-lab-infrastructure

Personal home lab infrastructure managed as code. This repository contains the Terraform configurations, bootstrap scripts, and operational tooling for all machines running in my home lab environment.

---

## Repository Structure

```
home-lab-infrastructure/
├── docs/                                        # Operational documentation and runbooks
├── node/
│   ├── _common/                                 # Shared configuration and scripts for all nodes
│   │   └── scripts/                             # General-purpose operational scripts
│   └── <node-hostname>/
│       ├── bootstrap/                           # Machine bootstrap and initial OS installation files
│       └── containers/                          # Terraform configuration for Docker containers
└── README.md
```

---

## Documentation

See [docs/README.md](docs/README.md) for detailed operational documentation.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Contributions

This is a personal repository. External contributions are not accepted.