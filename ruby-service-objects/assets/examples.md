# ruby-service-objects examples

1) Simple usage

```
result = MyService.call(user_id: user.id)
if result[:success]
  # use result[:response]
else
  # handle error
end
```

2) Error shape example

```
{ success: false, response: { error: 'External API timeout' } }
```
