function dclean --description "Force remove all Docker containers"
    set containers (docker ps -aq)
    if test -n "$containers"
        docker rm -f $containers
        echo "✅ Deleted all Docker containers."
    else
        echo "ℹ️ No Docker containers found."
    end
end
