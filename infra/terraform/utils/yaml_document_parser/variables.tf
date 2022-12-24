variable "parser_url_names" {
  type    = list(string)
  default = []
}

variable "parser_file_names" {
  type    = list(string)
  default = []
}

variable "parser_file_path" {
  type    = string
  default = ""
}

variable "parser_url_path" {
  type    = string
  default = ""
}

variable "url_filter" {
  type = set(string)
  default = []
}

variable "file_filter" {
  type = set(string)
  default = []
}


