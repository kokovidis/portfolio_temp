import * as React from "react"
import { PropertyControls, ControlType } from "framer"

interface Props {
    title: string
    backItemTitle: string
    rightItemTitle: string
    showChevron: boolean
    appearance: "dark" | "light" | "custom"
    tintColor: string
    textColor: string
    customBackground: string
    backAction: () => void
    rightItemAction: () => void
    width: number
    height: number
}

export class NavigationBar extends React.Component<Partial<Props>> {
    static defaultProps = {
        title: "Title",
        backItemTitle: "Previous",
        rightItemTitle: "Edit",
        showChevron: true,
        appearance: "light",
        tintColor: "#007AFF",
        textColor: "black",
        customBackground: "#09F",
        width: 375,
        height: 64,
    }

    static propertyControls: PropertyControls<Props> = {
        title: { type: ControlType.String, title: "Title" },
        backItemTitle: { type: ControlType.String, title: "BackTitle" },
        rightItemTitle: { type: ControlType.String, title: "RightTitle" },
        showChevron: { type: ControlType.Boolean, title: "Chevron" },
        appearance: {
            type: ControlType.Enum,
            options: ["dark", "light", "custom"],
            optionTitles: ["Dark", "Light", "Custom"],
            title: "Appearance",
        },
        customBackground: {
            type: ControlType.Color,
            title: " ",
            hidden(props) {
                return props.appearance !== "custom"
            },
        },
        tintColor: { type: ControlType.Color, title: "Tint" },
        textColor: { type: ControlType.Color, title: "Text" },
    }

    render() {
        const {
            title,
            backItemTitle,
            rightItemTitle,
            showChevron,
            tintColor,
            textColor,
            customBackground,
            appearance,
            backAction,
            rightItemAction,
            width,
            height,
        } = this.props

        let backgroundColor = "rgba(33,33,33,.72"
        let boxShadow = "inset 0 -1px 0 -0.5px rgba(255,255,255,.16)"

        switch (appearance) {
            case "light":
                boxShadow = "inset 0 -1px 0 -0.5px rgba(0,0,0,.05)"
                backgroundColor = "rgba(248,248,248,.82)"
                break
            case "custom":
                backgroundColor = customBackground
        }

        return (
            <div
                style={{
                    width,
                    height,
                    backgroundColor,
                    color: tintColor,
                    backdropFilter: "blur(10px)",
                    boxShadow,
                    fontSize: 17,
                    padding: "32px 16px 0",
                    display: "flex",
                    justifyContent: "space-between",
                }}
            >
                <div
                    style={{
                        flexGrow: 2,
                        flexShrink: 0,
                        height: 20,
                        width: 10,
                        textAlign: "left",
                    }}
                    onClick={backAction}
                >
                    {showChevron && (
                        <div
                            style={{ float: "left", marginLeft: -7, marginRight: 7 }}
                            dangerouslySetInnerHTML={{ __html: chevron(tintColor) }}
                        />
                    )}
                    {backItemTitle}
                </div>
                <div style={{ color: textColor }}>{title}</div>
                <div
                    style={{
                        flexGrow: 2,
                        flexShrink: 0,
                        height: 20,
                        width: 10,
                        textAlign: "right",
                    }}
                    onClick={rightItemAction}
                >
                    {rightItemTitle}
                </div>
            </div>
        )
    }
}

function chevron(tint: string) {
    return `<?xml version="1.0" encoding="UTF-8"?>
    <svg width="13px" height="21px" viewBox="0 0 13 21" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <g id="Symbols" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
            <g id="Bars/Navigation-Bar/_/Light/Left-Combinations/Back-Button" transform="translate(-8.000000, -11.000000)" fill="${tint}">
                <path d="M18.0371349,31.5826673 L8.79215185,22.4458042 C8.40261605,22.0611888 8.40261605,21.4398102 8.79215185,21.0541958 L18.0371349,11.9173327 C18.5994648,11.3608891 19.5143745,11.3608891 20.0777032,11.9173327 C20.6400331,12.4737762 20.6400331,13.3768731 20.0777032,13.9333167 L12.1691276,21.7504995 L20.0777032,29.5656843 C20.6400331,30.1231269 20.6400331,31.0262238 20.0777032,31.5826673 C19.5143745,32.1391109 18.5994648,32.1391109 18.0371349,31.5826673" id="Chevron"></path>
            </g>
        </g>
    </svg>`
}
