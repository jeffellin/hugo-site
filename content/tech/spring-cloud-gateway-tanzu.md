+++
title = "Spring Cloud Gateway for Tanzu"
date = 2020-07-14T00:35:15-04:00
tags = ["spring","gateway"]
category = ["tech"]
featured_image = ""
description = "Spring Cloud for Tanzu"
draft = "false"
+++

1. Create the Gateway for the service.

    ```
    {
        "host":"jeff-gateway2"
    }
    ```

2. Bind the app using the following config. uri will be added automatically.  If available an internal route will be preferred.

    ```
    {
        "routes": [
            {
                "predicates":["RemoteAddr=10.1.7.1/24"],
                "filters":["StripPrefix=0"]
            }
        ]

    }
    ```