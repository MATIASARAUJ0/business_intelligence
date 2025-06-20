{% macro drop_schemas() %}
    {% set schemas = ['RAW', 'STAGING', 'MASTER'] %}

    {% for schema in schemas %}
        {% do run_query("IF EXISTS (SELECT * FROM sys.schemas WHERE name = '" ~ schema ~ "') BEGIN EXEC('DROP SCHEMA " ~ schema ~ "') END") %}
    {% endfor %}
{% endmacro %}