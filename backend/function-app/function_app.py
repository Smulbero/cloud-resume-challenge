import azure.functions as func
import logging
import os
from azure.data.tables import TableServiceClient
from azure.identity import DefaultAzureCredential

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

def get_table_client():
    endpoint = os.environ["COSMOS_TABLE_ENDPOINT"]
    credential = DefaultAzureCredential()

    return TableServiceClient(endpoint=endpoint, credential=credential)

@app.route(route="visitor-count", methods=["GET"])
def visitor_count(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Visitor count function triggered")

    try:
        table_name = os.environ["COSMOS_TABLE_NAME"]
        table = get_table_client().get_table_client(table_name)

        partition_key = os.environ["PARTITION_KEY"]
        row_key = os.environ["ROW_KEY"]

        entity = table.get_entity(
            partition_key=partition_key, 
            row_key=row_key
        )
        entity["Count"] += 1
        table.upsert_entity(entity)

        return func.HttpResponse(
            body=f'{{"count": {entity["Count"]}}}',
            mimetype="application/json",
            status_code=200
        )
    except Exception as e:
        logging.error(f"Error updating visitor count: {e}")
        return func.HttpResponse(
            body='{"error": "Something went wrong"}',
            mimetype="application/json",
            status_code=500
        )