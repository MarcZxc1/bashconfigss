function dpsql --description "Connect to the running PostgreSQL docker container"
    set container (docker ps --filter "name=postgres" --format "{{.Names}}" | head -n 1)
    if test -n "$container"
        echo "🔌 Connecting to $container..."
        docker exec -it $container psql -U postgres
    else
        echo "ℹ️ No running postgres container found."
    end
end
