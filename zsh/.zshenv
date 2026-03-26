export BUN_INSTALL="$HOME/.bun"

case ":${PATH}:" in
  *:"$HOME/.local/bin":*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

case ":${PATH}:" in
  *:"$BUN_INSTALL/bin":*) ;;
  *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac
