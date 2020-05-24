import * as React from "react"
import { PropertyControls, ControlType } from "framer"

interface Props {
    title: string
    action1: string
    action2: string
    action3: string
    action4: string
    tintColor: string
    dimOverlay: boolean
    onTapAction: (index: number, label: string) => void
    onCancel: () => void
    width: number
    height: number
}

export class ActionSheet extends React.Component<Partial<Props>> {
    static defaultProps = {
        title: "A short description of the actions goes here.",
        action1: "Action 1",
        action2: "Action 2",
        action3: "",
        action4: "",
        tintColor: "#007AFF",
        dimOverlay: true,
        width: 375,
        height: 375,
    }

    static propertyControls: PropertyControls<Props> = {
        title: { type: ControlType.String, title: "Title" },
        action1: { type: ControlType.String, title: "Action 1" },
        action2: { type: ControlType.String, title: "Action 2" },
        action3: { type: ControlType.String, title: "Action 3" },
        action4: { type: ControlType.String, title: "Action 4" },
        tintColor: { type: ControlType.Color, title: "Tint" },
        dimOverlay: { type: ControlType.Boolean, disabledTitle: "Hide", enabledTitle: "Show", title: "DimOverlay" },
    }

    onTapAction = (index: number) => {
        const { onTapAction } = this.props
        if (!onTapAction) return
        const actionTitle = this.actionTitles()[index]
        onTapAction(index, actionTitle)
    }

    actionTitles = () => {
        const { action1, action2, action3, action4 } = this.props
        return [action1, action2, action3, action4].filter(action => action.length > 0)
    }

    render() {
        const { title, tintColor, dimOverlay, width, height } = this.props
        const buttonWidth = width - 16

        const actionTitles = this.actionTitles()

        const buttons = actionTitles.map((acionTitle, index) => {
            const isTop = title.length === 0 && index === 0
            const isBottom = index === actionTitles.length - 1

            return (
                <div
                    style={{
                        width: buttonWidth,
                        height: 56,
                        lineHeight: "56px",
                        textAlign: "center",
                        borderTopLeftRadius: isTop ? 14 : 0,
                        borderTopRightRadius: isTop ? 14 : 0,
                        borderBottomLeftRadius: isBottom ? 14 : 0,
                        borderBottomRightRadius: isBottom ? 14 : 0,
                        background: "rgba(248,248,248,.82)",
                        boxShadow: isBottom ? undefined : dividerShadow,
                        backdropFilter: "blur(20px)",
                    }}
                    key={index}
                    onClick={this.onTapAction.bind(this, index)}
                >
                    {acionTitle}
                </div>
            )
        })

        return (
            <div
                style={{
                    width,
                    height,
                    color: tintColor,
                    fontSize: 20,
                    display: "flex",
                    flexDirection: "column",
                    justifyContent: "flex-end",
                    alignItems: "center",
                    background: dimOverlay ? "rgba(4,4,15,.4)" : undefined,
                }}
            >
                {title && (
                    <div
                        style={{
                            width: buttonWidth,
                            height: 45,
                            lineHeight: "45px",
                            textAlign: "center",
                            borderTopLeftRadius: 14,
                            borderTopRightRadius: 14,
                            background: "rgba(248,248,248,.82)",
                            fontSize: 13,
                            color: "#8E8E93",
                            boxShadow: actionTitles.length > 0 ? dividerShadow : undefined,
                            backdropFilter: "blur(20px)",
                        }}
                        onClick={this.props.onCancel}
                    >
                        {title}
                    </div>
                )}
                {buttons}
                <div
                    style={{
                        width: width - 16,
                        height: 56,
                        lineHeight: `${56}px`,
                        textAlign: "center",
                        borderRadius: 14,
                        marginTop: 8,
                        marginBottom: 10,
                        background: "white",
                    }}
                >
                    Cancel
                </div>
            </div>
        )
    }
}

const dividerShadow = "inset 0 -1px 0 -0.5px rgba(0,0,0,.05)"
