import * as React from "react"
import { PropertyControls, ControlType } from "framer"

interface Props {
    appearance: "dark" | "light"
    action1: string
    action2: string
    action3: string
    action4: string
    tintColor: string
    onTapAction: (index: number, label: string) => void
    width: number
    height: number
}

export class Toolbar extends React.Component<Partial<Props>> {
    static defaultProps = {
        action1: "Action 1",
        action2: "Action 2",
        action3: "Action 3",
        action4: "",
        appearance: "light",
        tintColor: "#007AFF",
        width: 375,
        height: 44,
    }

    static propertyControls: PropertyControls<Props> = {
        action1: { type: ControlType.String, title: "Action 1" },
        action2: { type: ControlType.String, title: "Action 2" },
        action3: { type: ControlType.String, title: "Action 3" },
        action4: { type: ControlType.String, title: "Action 4" },
        appearance: {
            type: ControlType.Enum,
            options: ["dark", "light"],
            optionTitles: ["Dark", "Light"],
            title: "Appearance",
        },
        tintColor: { type: ControlType.Color, title: "Tint" },
    }

    onTapAction = (index: number) => {
        const { onTapAction } = this.props
        if (onTapAction) {
            const label = this.actionsLabels()[index]
            onTapAction(index, label)
        }
    }

    private actionsLabels = () => {
        const { action1, action2, action3, action4 } = this.props
        return [action1, action2, action3, action4].filter(label => label.length > 0)
    }

    render() {
        const { width, height, tintColor, appearance } = this.props

        const items: JSX.Element[] = this.actionsLabels().map((label, index) => {
            return (
                <div key={index} onClick={this.onTapAction.bind(this, index)}>
                    {label}
                </div>
            )
        })

        const isDark = appearance === "dark"
        const backgroundColor = isDark ? "rgba(33,33,33,.72)" : "rgba(248,248,248,.82)"
        const boxShadow = isDark ? "inset 0 1px 0 -0.5px rgba(255,255,255,.16)" : "inset 0 1px 0 -0.5px rgba(0,0,0,.05)"

        return (
            <div
                style={{
                    width,
                    height,
                    backgroundColor,
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "0 16px",
                    color: tintColor,
                    backdropFilter: "blur(10px)",
                    boxShadow,
                }}
            >
                {items}
            </div>
        )
    }
}
