function ddbs --description "List all databases in the running PostgreSQL docker container"
    set container (docker ps --filter "name=postgres" --format "{{.Names}}" | head -n 1)
    if test -n "$container"
        echo "📂 Listing databases in $container..."
        docker exec -it $container psql -U postgres -l
    else
        echo "ℹ️ No running postgres container found."
    end
end
