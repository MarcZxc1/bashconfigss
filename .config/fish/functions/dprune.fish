function dprune --description "Nuke all Docker containers, networks, volumes, and images"
    echo "⚠️  Nuking all Docker containers, networks, images, and volumes..."
    docker system prune -a -f --volumes
    echo "✅ Docker is completely clean."
end
