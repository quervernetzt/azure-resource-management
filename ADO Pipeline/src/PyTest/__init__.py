import logging
import azure.functions as func
import requests


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Azure Function has been triggered...")

    response: str = ""
    status_code: int = -1

    request_url: str = req.params.get("url")
    if not request_url:
        response = "Please specify a url..."
        status_code = 400
    else:
        try:
            request_response: requests.Response = requests.get(request_url)
            response = request_response.content
            status_code = 200
        except Exception as e:
            logging.error("Request failed...")
            response = e.args[0]
            # should actually be more granular but this is fine for demonstration purposes
            status_code = 500

    return func.HttpResponse(
        response,
        status_code=status_code
    )
