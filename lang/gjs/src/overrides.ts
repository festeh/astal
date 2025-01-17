/**
 * Workaround for "Can't convert non-null pointer to JS value "
 */

export { }

const snakeify = (str: string) => str
    .replace(/([a-z])([A-Z])/g, "$1_$2")
    .replaceAll("-", "_")
    .toLowerCase()

async function suppress<T>(mod: Promise<{ default: T }>, patch: (m: T) => void) {
    return mod.then(m => patch(m.default)).catch(() => void 0)
}

function patch<P extends object>(proto: P, prop: Extract<keyof P, string>) {
    Object.defineProperty(proto, prop, {
        get() { return this[`get_${snakeify(prop)}`]() },
    })
}

await suppress(import("gi://AstalApps"), ({ Apps, Application }) => {
    patch(Apps.prototype, "list")
    patch(Application.prototype, "keywords")
    patch(Application.prototype, "categories")
})

await suppress(import("gi://AstalBattery"), ({ UPower }) => {
    patch(UPower.prototype, "devices")
})

await suppress(import("gi://AstalBluetooth"), ({ Adapter, Bluetooth, Device }) => {
    patch(Adapter.prototype, "uuids")
    patch(Bluetooth.prototype, "adapters")
    patch(Bluetooth.prototype, "devices")
    patch(Device.prototype, "uuids")
})

await suppress(import("gi://AstalHyprland"), ({ Hyprland, Monitor, Workspace }) => {
    patch(Hyprland.prototype, "monitors")
    patch(Hyprland.prototype, "workspaces")
    patch(Hyprland.prototype, "clients")
    patch(Monitor.prototype, "availableModes")
    patch(Monitor.prototype, "available_modes")
    patch(Workspace.prototype, "clients")
})

await suppress(import("gi://AstalMpris"), ({ Mpris, Player }) => {
    patch(Mpris.prototype, "players")
    patch(Player.prototype, "supported_uri_schemas")
    patch(Player.prototype, "supportedUriSchemas")
    patch(Player.prototype, "supported_mime_types")
    patch(Player.prototype, "supportedMimeTypes")
    patch(Player.prototype, "comments")
})

await suppress(import("gi://AstalNetwork"), ({ Wifi }) => {
    patch(Wifi.prototype, "access_points")
    patch(Wifi.prototype, "accessPoints")
})

await suppress(import("gi://AstalNotifd"), ({ Notifd, Notification }) => {
    patch(Notifd.prototype, "notifications")
    patch(Notification.prototype, "actions")
})

await suppress(import("gi://AstalPowerProfiles"), ({ PowerProfiles }) => {
    patch(PowerProfiles.prototype, "actions")
})
