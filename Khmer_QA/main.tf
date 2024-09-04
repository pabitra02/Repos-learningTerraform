module "Khmer_QA" {
    source = "../module/Khmer_web"

    environment = {
        name            = "Khmer_QA"
        network_prefix  = "10.1"

    }

    asg_min_size = 1
    asg_max_size = 1

}