import * as React from "react"
import { Frame, animate, PropertyControls, ControlType, FramerAnimation, PropertyStore, RenderTarget } from "framer"

interface Props {
    enabled: boolean
    onChange: (enabled: boolean) => void
    tint: string
    width: number
    height: number
}

interface State {
    enabled: boolean
    externalEnabled: boolean
}

export class Switch extends React.Component<Partial<Props>, State> {
    static defaultProps = {
        width: 51,
        height: 31,
        enabled: true,
        tint: "#4BD964",
    }

    static propertyControls: PropertyControls<Props> = {
        enabled: { type: ControlType.Boolean, title: "Enabled" },
        tint: { type: ControlType.Color, title: "Tint" },
    }

    state = {
        enabled: false,
        externalEnabled: false,
    }

    switch = PropertyStore({ left: 0, dimScale: 1 }, true)
    animation: FramerAnimation<any, any> | undefined = undefined

    componentDidMount() {
        const { enabled } = this.props
        this.setState({ ...this.state, enabled })
        this.transition(enabled, false)
    }

    static getDerivedStateFromProps(nextProps: Props, prevState: State) {
        const { enabled } = nextProps
        if (enabled !== prevState.externalEnabled) {
            return { enabled, externalEnabled: enabled }
        }
        return null
    }

    onTap = () => {
        const enabled = !this.state.enabled
        const { onChange } = this.props
        if (onChange) {
            onChange(enabled)
        } else {
            this.setState({ ...this.state, enabled })
        }
    }

    transition(enabled: boolean, shouldAnimate = true) {
        if (this.animation) {
            this.animation.cancel()
            this.animation = undefined
        }
        const { width, height } = this.props
        const knobWidth = height - 2
        const left = enabled ? width - knobWidth - 1 : 1
        const dimScale = enabled ? 0 : 1
        if (shouldAnimate && RenderTarget.current() === RenderTarget.preview) {
            const springOptions = { tension: 250, friction: 25 }
            this.animation = animate.spring(this.switch, { left, dimScale }, springOptions)
        } else {
            this.switch.left = left
            this.switch.dimScale = dimScale
        }
    }

    render() {
        const { tint, width, height } = this.props
        const { enabled } = this.state
        this.transition(enabled)
        return (
            <Frame
                width={width}
                height={height}
                background={tint}
                onTap={this.onTap}
                style={{
                    borderRadius: 1000,
                }}
            >
                <Frame
                    background={"#F8F8F8"}
                    top={0}
                    left={0}
                    right={0}
                    bottom={0}
                    scale={this.switch.dimScale}
                    scaleX={1}
                    style={{
                        borderRadius: 1000,
                        boxShadow: "inset 0 0 0 1px #E4E4E4",
                    }}
                />
                <Frame
                    background={"white"}
                    top={1}
                    bottom={1}
                    left={this.switch.left}
                    aspectRatio={1}
                    style={{
                        borderRadius: 1000,
                        boxShadow: "0 2px 1px 1px rgba(0,0,0,.07), 0 0 1px rgba(0,0,0,.3)",
                    }}
                />
            </Frame>
        )
    }
}
