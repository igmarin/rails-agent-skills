# ruby-service-objects examples

1) Simple usage from controller

```ruby
result = AnimalTransfers::TransferService.call(source_shelter_id: 1, target_shelter_id: 2, tag_number: 'ABC-123')
if result[:success]
  render json: result[:response], status: :ok
else
  render json: { error: result[:response][:error][:message] }, status: :unprocessable_entity
end
```

1) Orchestrator — early return on sub-service failure

```ruby
result = UserCreationService.call(params)
return result unless result[:success]

workspace_result = WorkspaceSetupService.call(user_id: result[:response][:user].id)
return workspace_result unless workspace_result[:success]

{ success: true, response: { user: result[:response][:user], workspace: workspace_result[:response][:workspace] } }
```

1) Batch — partial success with per-item error tracking

```ruby
results = items.each_with_object({ successful: [], failed: [] }) do |item, acc|
  process_item(item)
  acc[:successful] << item[:sku]
rescue StandardError => e
  Rails.logger.error("Item error: #{e.message}")
  acc[:failed] << { sku: item[:sku], error: e.message }
end
{ success: true, response: results }
```

1) Validator usage from a service

```ruby
def call
  error = PackageValidator.validate(@dimensions)
  return { success: false, response: { error: { message: error } } } if error

  # proceed with business logic
end
```

1) Correct error shape

```ruby
{ success: false, response: { error: { message: 'External API timeout' } } }
```
