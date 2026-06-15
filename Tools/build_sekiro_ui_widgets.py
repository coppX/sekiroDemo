import asyncio
import json
from typing import Any, Dict

HOST = "127.0.0.1"
PORT = 55557


class UmgClient:
    async def send(self, command: str, params: Dict[str, Any] | None = None) -> Dict[str, Any]:
        reader = None
        writer = None
        try:
            reader, writer = await asyncio.open_connection(HOST, PORT)
            payload = {"command": command, "params": params or {}}
            writer.write(json.dumps(payload).encode("utf-8") + b"\0")
            await writer.drain()

            chunks = []
            while True:
                chunk = await reader.read(4096)
                if not chunk:
                    break
                if b"\0" in chunk:
                    chunks.append(chunk[:chunk.find(b"\0")])
                    break
                chunks.append(chunk)

            raw = b"".join(chunks).decode("utf-8")
            if not raw:
                raise RuntimeError(f"Empty response for command: {command}")
            return json.loads(raw)
        finally:
            if writer:
                writer.close()
                await writer.wait_closed()

    async def call(self, command: str, params: Dict[str, Any] | None = None) -> Dict[str, Any]:
        response = await self.send(command, params)
        if response.get("status") == "error" or response.get("success") is False:
            raise RuntimeError(f"{command} failed: {json.dumps(response, ensure_ascii=False)}")
        return response


def canvas_slot(
    x: float,
    y: float,
    w: float,
    h: float,
    anchors: Dict[str, Any] | None = None,
    alignment: list[float] | None = None,
) -> Dict[str, Any]:
    props: Dict[str, Any] = {
        "Slot.Position": [x, y],
        "Slot.Size": [w, h],
    }
    if anchors:
        props["Slot.Anchors"] = anchors
    if alignment:
        props["Slot.Alignment"] = alignment
    return props


def text_color(r: float, g: float, b: float, a: float = 1.0) -> Dict[str, Any]:
    return {"SpecifiedColor": {"R": r, "G": g, "B": b, "A": a}}


def text_props(x: float, y: float, w: float, h: float, text: str, size: int, color: Dict[str, Any]) -> Dict[str, Any]:
    return {
        **canvas_slot(x, y, w, h),
        "Text": text,
        "Font": {"Size": size},
        "ColorAndOpacity": color,
    }


async def set_target(client: UmgClient, asset_path: str) -> None:
    await client.call("set_target_umg_asset", {"asset_path": asset_path})


async def create_widget(client: UmgClient, widget_type: str, widget_name: str, parent_name: str = "") -> None:
    await client.call(
        "create_widget",
        {
            "widget_type": widget_type,
            "new_widget_name": widget_name,
            "parent_name": parent_name,
        },
    )


async def set_props(client: UmgClient, widget_name: str, properties: Dict[str, Any]) -> None:
    await client.call(
        "set_widget_properties",
        {
            "widget_name": widget_name,
            "properties": properties,
        },
    )


async def save(client: UmgClient) -> None:
    await client.call("save_asset")


async def build_main_menu(client: UmgClient) -> None:
    asset_path = "/Game/UI/Widgets/Menu/WBP_SekiroMainMenu"
    await set_target(client, asset_path)

    await create_widget(client, "CanvasPanel", "RootCanvas")

    await create_widget(client, "Border", "Border_BackgroundTint", "RootCanvas")
    await set_props(
        client,
        "Border_BackgroundTint",
        {
            **canvas_slot(0.0, 0.0, 1280.0, 720.0),
            "BrushColor": {"R": 0.0, "G": 0.0, "B": 0.0, "A": 1.0},
        },
    )

    await create_widget(client, "Image", "Img_MenuBackdrop", "RootCanvas")
    await set_props(
        client,
        "Img_MenuBackdrop",
        {
            **canvas_slot(176.0, 118.0, 928.0, 430.0),
            "RenderOpacity": 0.18,
        },
    )

    await create_widget(client, "Image", "Img_Background", "RootCanvas")
    await set_props(
        client,
        "Img_Background",
        {
            **canvas_slot(88.0, 52.0, 1104.0, 382.0),
            "RenderOpacity": 0.94,
        },
    )

    await create_widget(client, "Image", "Img_Selection", "RootCanvas")
    await set_props(
        client,
        "Img_Selection",
        {
            **canvas_slot(546.0, 503.0, 196.0, 28.0),
            "RenderOpacity": 0.82,
        },
    )

    text_specs = [
        ("Txt_NewGame", 578.0, 503.0, 176.0, 30.0, "NEW GAME", 28, text_color(0.95, 0.78, 0.45, 1.0)),
        ("Txt_Login", 604.0, 539.0, 120.0, 24.0, "LOG IN", 22, text_color(0.75, 0.75, 0.75, 0.95)),
        ("Txt_Settings", 586.0, 574.0, 156.0, 24.0, "SETTINGS", 22, text_color(0.75, 0.75, 0.75, 0.95)),
        ("Txt_Language", 582.0, 608.0, 174.0, 24.0, "LANGUAGE", 22, text_color(0.75, 0.75, 0.75, 0.95)),
        ("Txt_Quit", 586.0, 642.0, 160.0, 24.0, "QUIT GAME", 22, text_color(0.75, 0.75, 0.75, 0.95)),
    ]

    for name, x, y, w, h, text, size, color in text_specs:
        await create_widget(client, "TextBlock", name, "RootCanvas")
        await set_props(client, name, text_props(x, y, w, h, text, size, color))

    button_specs = [
        ("Btn_NewGame", 544.0, 500.0, 204.0, 32.0),
        ("Btn_Login", 560.0, 535.0, 172.0, 28.0),
        ("Btn_Settings", 558.0, 570.0, 178.0, 28.0),
        ("Btn_Language", 558.0, 604.0, 184.0, 28.0),
        ("Btn_Quit", 558.0, 638.0, 182.0, 28.0),
    ]

    for name, x, y, w, h in button_specs:
        await create_widget(client, "Button", name, "RootCanvas")
        await set_props(
            client,
            name,
            {
                **canvas_slot(x, y, w, h),
                "RenderOpacity": 0.0,
                "ToolTipText": name,
            },
        )

    await create_widget(client, "TextBlock", "Txt_Offline", "RootCanvas")
    await set_props(
        client,
        "Txt_Offline",
        text_props(1116.0, 650.0, 100.0, 18.0, "OFFLINE", 14, text_color(0.45, 0.45, 0.45, 0.9)),
    )

    await create_widget(client, "TextBlock", "Txt_Version", "RootCanvas")
    await set_props(
        client,
        "Txt_Version",
        text_props(1092.0, 675.0, 124.0, 18.0, "App Ver. 1.06", 14, text_color(0.45, 0.45, 0.45, 0.9)),
    )

    await create_widget(client, "TextBlock", "Txt_Copyright", "RootCanvas")
    await set_props(
        client,
        "Txt_Copyright",
        text_props(
            286.0,
            678.0,
            720.0,
            18.0,
            "2019,2020 FromSoftware, Inc. All rights reserved. ACTIVISION is a trademark of Activision Publishing, Inc.",
            12,
            text_color(0.46, 0.46, 0.46, 0.95),
        ),
    )

    await save(client)
    print(f"Built {asset_path}")


async def build_hud(client: UmgClient) -> None:
    asset_path = "/Game/UI/Widgets/HUD/WBP_SekiroHUD"
    await set_target(client, asset_path)

    await create_widget(client, "CanvasPanel", "RootCanvas")

    await create_widget(client, "Image", "Img_Background", "RootCanvas")
    await set_props(
        client,
        "Img_Background",
        {
            **canvas_slot(0.0, 0.0, 1280.0, 720.0),
            "RenderOpacity": 0.95,
        },
    )

    await create_widget(client, "Image", "Img_DamageVignette", "RootCanvas")
    await set_props(
        client,
        "Img_DamageVignette",
        {
            **canvas_slot(0.0, 0.0, 1280.0, 720.0),
            "RenderOpacity": 0.55,
        },
    )

    await create_widget(client, "Image", "Img_TopRightLine", "RootCanvas")
    await set_props(
        client,
        "Img_TopRightLine",
        {
            **canvas_slot(944.0, 26.0, 246.0, 18.0),
            "RenderOpacity": 0.65,
        },
    )

    await create_widget(client, "TextBlock", "Txt_EmblemCount", "RootCanvas")
    await set_props(
        client,
        "Txt_EmblemCount",
        {
            **canvas_slot(958.0, 16.0, 40.0, 24.0),
            "Text": "0",
            "Font": {"Size": 18},
            "ColorAndOpacity": {"SpecifiedColor": {"R": 0.85, "G": 0.95, "B": 1.0, "A": 1.0}},
        },
    )

    await create_widget(client, "Border", "Border_TutorialPanel", "RootCanvas")
    await set_props(
        client,
        "Border_TutorialPanel",
        {
            **canvas_slot(86.0, 250.0, 306.0, 34.0),
            "BrushColor": {"R": 0.06, "G": 0.06, "B": 0.06, "A": 0.78},
            "Padding": {"Left": 10.0, "Right": 12.0, "Top": 5.0, "Bottom": 5.0},
        },
    )

    await create_widget(client, "HorizontalBox", "HBox_Tutorial", "Border_TutorialPanel")
    await create_widget(client, "TextBlock", "Txt_TutorialButton", "HBox_Tutorial")
    await set_props(
        client,
        "Txt_TutorialButton",
        {
            "Text": "A",
            "Font": {"Size": 16},
            "ColorAndOpacity": {"SpecifiedColor": {"R": 0.68, "G": 0.82, "B": 0.46, "A": 1.0}},
            "Slot": {"Padding": {"Right": 8.0}},
        },
    )

    await create_widget(client, "TextBlock", "Txt_TutorialText", "HBox_Tutorial")
    await set_props(
        client,
        "Txt_TutorialText",
        {
            "Text": "in air near wall: Wall Jump",
            "Font": {"Size": 16},
            "ColorAndOpacity": {"SpecifiedColor": {"R": 0.9, "G": 0.9, "B": 0.9, "A": 1.0}},
        },
    )

    await create_widget(client, "Border", "Border_HealthFrame", "RootCanvas")
    await set_props(
        client,
        "Border_HealthFrame",
        {
            **canvas_slot(38.0, 616.0, 120.0, 10.0),
            "BrushColor": {"R": 0.05, "G": 0.05, "B": 0.05, "A": 0.9},
            "Padding": {"Left": 1.0, "Right": 1.0, "Top": 1.0, "Bottom": 1.0},
        },
    )

    await create_widget(client, "ProgressBar", "PB_Health", "RootCanvas")
    await set_props(
        client,
        "PB_Health",
        {
            **canvas_slot(40.0, 618.0, 116.0, 6.0),
            "Percent": 0.38,
            "FillColorAndOpacity": {"SpecifiedColor": {"R": 0.76, "G": 0.34, "B": 0.2, "A": 1.0}},
        },
    )

    await create_widget(client, "Border", "Border_MoneyPanel", "RootCanvas")
    await set_props(
        client,
        "Border_MoneyPanel",
        {
            **canvas_slot(1052.0, 437.0, 100.0, 34.0),
            "BrushColor": {"R": 0.0, "G": 0.0, "B": 0.0, "A": 0.35},
            "Padding": {"Left": 8.0, "Right": 8.0, "Top": 4.0, "Bottom": 4.0},
        },
    )

    await create_widget(client, "HorizontalBox", "HBox_Money", "Border_MoneyPanel")
    await create_widget(client, "TextBlock", "Txt_MoneyIcon", "HBox_Money")
    await set_props(
        client,
        "Txt_MoneyIcon",
        {
            "Text": "o",
            "Font": {"Size": 18},
            "ColorAndOpacity": {"SpecifiedColor": {"R": 0.75, "G": 0.63, "B": 0.38, "A": 1.0}},
            "Slot": {"Padding": {"Right": 8.0}},
        },
    )

    await create_widget(client, "TextBlock", "Txt_Money", "HBox_Money")
    await set_props(
        client,
        "Txt_Money",
        {
            "Text": "0",
            "Font": {"Size": 18},
            "ColorAndOpacity": {"SpecifiedColor": {"R": 0.92, "G": 0.92, "B": 0.92, "A": 1.0}},
        },
    )

    await create_widget(client, "Border", "Border_QuickItemPanel", "RootCanvas")
    await set_props(
        client,
        "Border_QuickItemPanel",
        {
            **canvas_slot(1006.0, 610.0, 44.0, 44.0),
            "BrushColor": {"R": 0.0, "G": 0.0, "B": 0.0, "A": 0.65},
            "Padding": {"Left": 2.0, "Right": 2.0, "Top": 2.0, "Bottom": 2.0},
        },
    )

    await save(client)
    print(f"Built {asset_path}")


async def main() -> None:
    client = UmgClient()
    await build_main_menu(client)
    await build_hud(client)


if __name__ == "__main__":
    asyncio.run(main())
