# Fixit Cloud ☁️ MODULE: AWS Network Security

TODO change below tag-line
Terraform modules for defining Fixit Cloud architecture.

---

### Network ACL Rule Numbering Outline

| Rules     | Protocol |    Ports     | CIDR Block           | Public Subnets Ingress | Public Subnets Egress | Private Subnets Ingress | Private Subnets Egress | Notes                   |
| :-------- | :------: | :----------: | :------------------- | :--------------------: | :-------------------: | :---------------------: | :--------------------: | :---------------------- |
| 100       |   HTTP   |      80      | 0.0.0.0/0 (anywhere) |           ✔️           |          ✔️           |                         |           ✔️           |                         |
| 101 - 199 |   HTTP   |      80      | Public Subnets       |                        |                       |           ✔️            |                        | Not used in production  |
| 200       |  HTTPS   |     443      | 0.0.0.0/0 (anywhere) |           ✔️           |          ✔️           |                         |           ✔️           |                         |
| 201 - 299 |  HTTPS   |     443      | Public Subnets       |                        |                       |           ✔️            |                        |                         |
| 300       |   SSH    |      22      | EC2 Instance Connect |           ✔️           |                       |                         |                        | Varies between regions  |
| 301 - 349 |   SSH    |      22      | Administrator IPs    |           ✔️           |                       |                         |                        | Not used in production  |
| 350       |   SSH    |      22      | Bastion private IP   |                        |                       |           ✔️            |                        | Not used in production  |
| 351 - 399 |   SSH    |      22      | Private Subnets      |                        |          ✔️           |                         |                        | Not used in production  |
| 400 - 499 |    -     |      -       | -                    |                        |                       |                         |                        | Reserved for future use |
| 500       |    -     | 1024 - 65535 | 0.0.0.0/0 (anywhere) |           ✔️           |          ✔️           |           ✔️            |           ✔️           | Ephemeral ports         |

> Note: SSH rules are only used in non-production VPCs that utilize ["pet" instances][pets-meme].

---

## License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

## Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - T.AndersonProperty@gmail.com

[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[pre-commit-shield]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
[fixit-cloud-live]: https://github.com/Nerdware-LLC/fixit-cloud-live
[pets-meme]: https://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/
[linkedin-url]: https://www.linkedin.com/in/trevor-anderson-3a3b0392/
[linkedin-shield]: https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white
