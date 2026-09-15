import api
from api import ResourceNotFoundError
from unittest.mock import patch, MagicMock
import pytest
from http import HTTPStatus
import json

@pytest.fixture
def environment(monkeypatch):
  monkeypatch.setenv("COSMOS_TABLE_NAME", "visitors")
  monkeypatch.setenv("PARTITION_KEY", "pk")
  monkeypatch.setenv("ROW_KEY", "rk")

@patch("api.get_table_client")
def test_new_visitor_entry(mock_get_table_client, environment):
  mock_table = MagicMock()
  mock_get_table_client.return_value.get_table_client.return_value = mock_table
  mock_table.get_entity.side_effect = ResourceNotFoundError()
  mock_response = api.visitor_count(MagicMock())
  body = json.loads(mock_response.get_body())
  
  assert mock_response.status_code == HTTPStatus.OK
  assert body["count"] == 1 

@patch("api.get_table_client")
def test_visitor_increment(mock_get_table_client, environment):    
  mock_table = MagicMock()
  mock_get_table_client.return_value.get_table_client.return_value = mock_table
  mock_dict = {
    "PartitionKey": "pk",
    "RowKey": "rk",
    "Count": 1
  }
  mock_table.get_entity.return_value = mock_dict
  mock_response = api.visitor_count(MagicMock()) 
  body = json.loads(mock_response.get_body())

  assert body["count"] == 2
  mock_table.upsert_entity.assert_called_once_with({
    "PartitionKey": "pk",
    "RowKey": "rk",
    "Count": 2
  })

@patch("api.get_table_client")
def test_exception_error_returns_500(mock_get_table_client, environment): 
  mock_get_table_client.side_effect = Exception(MagicMock())
  mock_response = api.visitor_count(MagicMock())
  body = json.loads(mock_response.get_body())
  
  assert mock_response.status_code == HTTPStatus.INTERNAL_SERVER_ERROR
  assert body["error"] == "Something went wrong"

