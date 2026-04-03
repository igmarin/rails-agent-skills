# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require_relative '../lib/mcp/request_handler'
require_relative '../lib/mcp/response'

# Integration tests for {MCP::RequestHandler} (ListResources, ReadResource, errors).
class MCPRequestHandlerTest < Minitest::Test
  def setup
    @mock_resource_locator = Minitest::Mock.new
    @handler = MCP::RequestHandler.new(resource_locator: @mock_resource_locator)
  end

  def test_handle_list_resources_request
    mock_resources = [{ uri: 'file:///fake/skill.md', name: 'skill/fake', mimeType: 'text/markdown' }]
    @mock_resource_locator.expect(:list_skill_resources, mock_resources)

    request = { 'method' => 'ListResources', 'requestId' => 'req1' }
    response = @handler.handle(request)

    expected_response = MCP::Response.success(mock_resources, request_id: 'req1')
    assert_equal expected_response, response
    @mock_resource_locator.verify
  end

  def test_handle_read_resource_request_success
    mock_content = '# Content of fake skill'
    mock_uri = 'file:///fake/skill.md'
    @mock_resource_locator.expect(:read_resource, mock_content, [mock_uri])

    request = { 'method' => 'ReadResource', 'requestId' => 'req2', 'params' => { 'uri' => mock_uri } }
    response = @handler.handle(request)

    expected_response = MCP::Response.success(mock_content, request_id: 'req2')
    assert_equal expected_response, response
    @mock_resource_locator.verify
  end

  def test_handle_read_resource_request_missing_uri
    request = { 'method' => 'ReadResource', 'requestId' => 'req3', 'params' => {} }
    response = @handler.handle(request)

    expected_response = MCP::Response.error('Missing URI for ReadResource', code: 400, request_id: 'req3')
    assert_equal expected_response, response
  end

  def test_handle_read_resource_request_file_not_found
    mock_uri = 'file:///non/existent/path/skill.md'
    # Minitest::Mock returns the second argument as-is; a Proc is not invoked, so use a real stub.
    failing_locator = Object.new
    failing_locator.define_singleton_method(:read_resource) do |_uri|
      raise Errno::ENOENT # bare errno => message "No such file or directory" (no duplicate)
    end
    handler = MCP::RequestHandler.new(resource_locator: failing_locator)

    request = { 'method' => 'ReadResource', 'requestId' => 'req4', 'params' => { 'uri' => mock_uri } }
    response = handler.handle(request)

    expected_response = MCP::Response.error('No such file or directory', code: 400, request_id: 'req4')
    assert_equal expected_response, response
  end

  def test_handle_unknown_method
    request = { 'method' => 'UnknownMethod', 'requestId' => 'req5' }
    response = @handler.handle(request)

    expected_response = MCP::Response.error('Unknown method: UnknownMethod', code: 400, request_id: 'req5')
    assert_equal expected_response, response
  end

  def test_handle_malformed_json_input
    # Simulate a JSON parsing error by directly calling handle with invalid input
    # This specific test case might be tricky if JSON.parse is called externally before handle
    # However, for robustness, RequestHandler should ideally handle or be shielded from raw input.
    # In our current design, JSON.parse is expected to happen before handle is called.
    # So, we test the rescue block around the external JSON.parse in the main server loop.
    # This test verifies the error path if JSON.parse error happens within handle due to some edge case.
    request = 'not valid json'
    response = @handler.handle(request) # This will raise if JSON.parse isn't in handler.handle

    expected_response = MCP::Response.error('JSON Parse Error: (original exception message not captured here)',
                                            code: 400)
    assert_equal expected_response[:error][:code], response[:error][:code]
    assert_includes response[:error][:message], 'JSON Parse Error'
    assert_nil response[:requestId]
  end
end
