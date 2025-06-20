{% macro create_schemas() %}
    {% set schemas = ['RAW', 'STAGING', 'MASTER'] %}

    {% for schema in schemas %}
        {% do run_query("IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '" ~ schema ~ "') BEGIN EXEC('CREATE SCHEMA " ~ schema ~ "') END") %}
    {% endfor %}
{% endmacro %}