select 
c.customer_state as state,
c.customer_zip_code_prefix as zip,
sum(p.payment_value) as revenue,
count(*) as number_of_payment,
from orders o
join customers c on c.customer_id = o.customer_id
join order_payments p on p.order_id = o.order_id

where 1=1

{% if (context.params.zip | is_integer) %}
  -- Check the ZIP code
  {% req geo %}
  select count(*) as count from geolocation where geolocation_zip_code_prefix = {{ context.params.zip }};
  {% endreq %}
  {% if geo.value()[0].count == 0 %}
    {% error "ZIP_CODE_NOT_FOUND" %}
  {% endif %}

  and c.customer_zip_code_prefix = {{ context.params.zip  }}
{% endif %}

{% if (context.params.state | is_string ) %}
  and c.customer_state = {{ context.params.state }}
{% endif %}

{% if context.user.attr.department != 'manager' %}
  and c.customer_state = {{ context.user.attr.state | is_required }}
{% endif %}

group by (c.customer_zip_code_prefix, c.customer_state) 
order by {{ context.params.order_by | is_enum(items=['zip', 'state', 'revenue', 'number_of_payment']) | default('zip') | raw }}

