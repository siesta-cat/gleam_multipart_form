import gleam/bit_array
import gleam/http
import gleam/http/request
import gleeunit
import gleeunit/should
import multipart_form
import multipart_form/field
import multipart_form/form

pub fn main() {
  gleeunit.main()
}

pub fn transitivity_test() {
  let assert Ok(test_image) =
    "/9j/4AAQSkZJRgABAQEAYABgAAD//gA7Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2NjIpLCBxdWFsaXR5ID0gOTAK/9sAQwADAgIDAgIDAwMDBAMDBAUIBQUEBAUKBwcGCAwKDAwLCgsLDQ4SEA0OEQ4LCxAWEBETFBUVFQwPFxgWFBgSFBUU/9sAQwEDBAQFBAUJBQUJFA0LDRQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU/8AAEQgAUABQAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/aAAwDAQACEQMRAD8A+d6KKK/rM/IgooooAKK9h+Af7L/ir9oF7y40qS20zRrNxFPqV5u2GTGfLRVGWYAgnoACMnkZ9Z13/gmz47soWk0rxDompuoz5UhlgZvYZVh+ZFeDiM9y7C1nQrVUpLp29eiO6ngcRVh7SEW0fItFdr8R/gv41+E10IfFPh670tHbbHdFRJbyH0WVSUJ9s59q4qvYo1qWIgqlKSlF9U7o5JwlTfLNWYUUUVsQFFFdr8FvhxP8Wfih4e8LQlkS/uQLiVOscCgvKw9witj3xWNatDD0pVqjtGKbfoi6cHUkoR3Z7N+y3+xrdfG6wfxH4iu7rRPC24x2xtlUT3jA4YoWBCoDxuIOTkAcEi/+1V+xlb/BLw1H4q8Nand6loaSpDdwahtM1uXOEcOoUMpbC4wCCR1zx+j+haJY+G9HstJ023S00+zhWCCCMYVEUYUD8BXxZ/wUG+P1gNIk+F+lEXN9LJDcarMD8sCqRJHF/vkhGPoAPXj8ey7PcyzPNo+xfuN6x6KPVvz8+/3H2GIwGGwuEfP8XfzPS/8AgnxGifs7WrKoDNqV0Wx3OVGfyAr6XzgZPFfNf/BPrP8AwznZY/6CN1/6EK0P25fEWq+FPgVNqejajdaXqEOpWpS5s5mikX5j0YHOPbvXy+YYd4vOatCLs5Tav6s9bD1FRwUajW0U/wAD3TXNDsPEml3OnapZQajYXKFJra5jEkci+hU8Gvzf/a8/ZCPwkMnizwnHLP4RlkAuLViXfTnY4HPVoyTgE8g4BzkGvdf2Pf2wp/indx+DfGckY8SiMtZaiqhFvwoyyMo4EgAJ44YA8Ajn6r1zRLHxJpF9pWo26Xdhewtb3EEgysiMMMD+Brpw+Ix3DGO9nU+a6SXdfo/kY1KeHzShzR36Pqn2Z+G9Fdr8Z/hxP8Jfif4g8KzFnSwuSIJW6yQMA8TH3KMuffNcVX9AUa0MRSjVpu8ZJNejPz6cHTk4S3QV9df8E2dCivfiz4g1SRQz2OklIyR91pJUGfyRh+NfItfXX/BNnXYrL4s+INLkYK19pRePP8TRyocfk7H8K+f4l5v7Jr8m9vwur/gehltvrUL9z9EtY1KPR9Ivb6UZitYHncD0VSx/lX4i+J/EN54t8R6nreoSGW+1C5kupmPd3Ysfw5r9utZ02PWNIvbGU4iuoHgcj0ZSp/nX4jeJ/D154S8R6nouoRmK90+5ktZ0PZ0Yqfw4r4fgT2XPX/m0+7X9T3s+5rQ7a/ofpX/wT2uop/2eoo45Vd4dTukkQHlGJVgD+DA/jR/wUJuYoP2epY5JVR5tTtkjUnl2BZiB+Ck/hXwJ8Ifj34y+B97cz+F9RSKC6IM9lcoJbeUjoSp6EeoIPvR8Xvj34y+OF9bTeKNRSWC2z9nsraMRW8JPUhR1J9SSfevQ/wBWMT/bP13mXs+bm8+9rf8ABOX+1KX1L2FnzWt5epx/hnxBeeE/EWma1p0phvdOuY7qBx2dGDD8OK/bnRdSj1nSLG/iH7q6gSdAewZQw/nX4jeGfD154t8RaZounxGW+1C5jtYEA6u7BR+HNftzoumxaLo9jp8R/dWsCQJn0VQo/lXn8d+z56Fvi1+7T9djqyHmtPtp95+dv/BSbQorH4s+H9VjUK99pQSQj+Jo5XGfydR+FfItfXX/AAUm12K9+LPh/So2DPY6SHkAP3Wklc4/JFP418i19xw3zf2TQ597fhd2/A8HMrfWp27hXa/Bj4jz/CX4n+H/ABVCGdLC5BniXrJAwKSqPcozY98VxVFfQVqMMRSlSqK8ZJp+jPPp1HTkpx3R+5Oh63Y+JNIsdV065S7sL2FJ7eeM5WRGGVI/A18qfthfsez/ABTupPGXg2OMeJxGFvdPZgi34UYVlY8CQAAc4DADkEc+E/shftfH4SGPwn4skln8IyyE290oLvpzscnjq0ZJyQOQckZyRX6QaHrlh4k0u31HS72DUbC4QPDc20gkjkX1DDg1/P8AiMNjuGMd7Snt0fSS7P8AVfcfoNOph81w/LLfquqfkfiV4h8Mav4S1KXT9a0y70q+iOHgvIWicfgwHHvR4e8M6v4t1KLTtE0y71W9kOEt7KBpXP4KDx71+3GpaLYazAIr+xtr6Ic7LmJZF/JgaXTdFsNFhMWn2NtYxHnZbxLGv5KBX1H+vc/Z29h73rp+V/keZ/YK5vj09NfzPlD9j39j24+Ft5H4z8ZxxnxKYytnpyMHWwDDDOzDgyEEjjhQTySePqvXtbsfDej3uq6jcJaWFnC1xcTyHCoijLE/gKXXNc0/w1pdzqWqXsGnWFuhea5upBHHGvqWPAr83/2vf2vm+LjSeE/CcksHhGKQG4umBR9QdTkcdVjBGQDyTgnGAK+Yw+Hx3FGO9pU+b6RXZfovvPTqVMPldDljv0XVvueF/Gn4jz/Fn4oeIfFMwZEv7km3ifrHAoCRKfcIq5981xVFFfv9GjDD0o0qatGKSXoj8+nN1JOct2FFFFbEhXa/Dj40+NfhLdGbwt4hu9LR23SWoYSW8h9WiYFCffGfeuKorGtRp4iDp1YqUX0aui6dSVN80HZn13oX/BSfx3ZQCPVfD+iam6jHmxiWBm9zhmH5AUmu/wDBSbx3ewGPSvD+iaY7DHmyiWdl+mWUfmDXyLRXz/8Aq1lPNzewV/nb7r2O/wDtLFWtzs7X4jfGfxr8WrsS+KvEF3qaI26O2LCO3jPqsSgID74z71xVFFfQUaNLDwVOlFRiuiVkcE5yqPmm7sKKKK2IP//Z"
    |> bit_array.base64_decode

  let bound = "test_bounds"

  let expected_form = [
    #("cat", field.String("mew")),
    #("dog", field.String("bark")),
    #("robot", field.File("test.jpg", "image/jpeg", test_image)),
  ]

  let assert Ok(actual_form) =
    expected_form |> form.to_bit_array(bound) |> form.from_bit_array(bound)

  actual_form |> should.equal(expected_form)
}

pub fn parses_request_test() {
  let expected_form = [
    #("one", field.String("one")),
    #("two", field.String("two")),
  ]

  let req =
    request.new()
    |> request.set_scheme(http.Https)
    |> request.set_method(http.Post)
    |> request.set_path("/index.html")
    |> request.set_host("siesta.cat")
    |> request.set_header("host", "siesta.cat")
    |> request.set_header(
      "content-type",
      "multipart/form-data; boundary=9923848",
    )
    |> request.set_body(<<
      "--9923848\r\n":utf8,
      "Content-Disposition: form-data; name=\"one\"\r\n\r\none\r\n":utf8,
      "--9923848\r\n":utf8,
      "Content-Disposition: form-data; name=\"two\"\r\n\r\ntwo\r\n":utf8,
      "--9923848--":utf8,
    >>)

  req |> multipart_form.from_request |> should.equal(Ok(expected_form))
}

pub fn to_request_test() {
  let base_req =
    request.new()
    |> request.set_scheme(http.Https)
    |> request.set_method(http.Post)
    |> request.set_path("/index.html")
    |> request.set_host("siesta.cat")
    |> request.set_header("host", "siesta.cat")

  let form = [
    #("describe", field.String("description")),
    #("content", field.String("disposed")),
  ]

  let expected_req =
    base_req
    |> request.set_header(
      "content-type",
      "multipart/form-data; boundary=gleam_multipart_form",
    )
    |> request.set_body(<<
      "--gleam_multipart_form\r\n":utf8,
      "Content-Disposition: form-data; name=\"describe\"\r\n\r\ndescription\r\n":utf8,
      "--gleam_multipart_form\r\n":utf8,
      "Content-Disposition: form-data; name=\"content\"\r\n\r\ndisposed\r\n":utf8,
      "--gleam_multipart_form--":utf8,
    >>)

  base_req
  |> multipart_form.to_request(form)
  |> should.equal(expected_req)
}
