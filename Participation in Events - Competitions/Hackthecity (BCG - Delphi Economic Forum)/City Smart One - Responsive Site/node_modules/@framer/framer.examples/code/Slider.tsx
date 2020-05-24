import * as React from "react"
import { Frame, Point, Draggable, PropertyControls, ControlType } from "framer"

interface Props {
    value: number
    onValueChange: (value: number) => void
    knob: string
    track: string
    tint: string
    width: number
    height: number
}

interface State {
    value: number
    externalValue: number
}

export class Slider extends React.Component<Partial<Props>, State> {
    static defaultProps = {
        width: 120,
        height: 44,
        value: 50,
        knob: "white",
        track: "#A4AAB3",
        tint: "#007AFF",
    }

    static propertyControls: PropertyControls<Props> = {
        value: { type: ControlType.Number, title: "Value" },
        tint: { type: ControlType.Color, title: "Tint" },
    }

    static knobSize = 28

    state = {
        value: Slider.defaultProps.value,
        externalValue: Slider.defaultProps.value,
    }

    componentDidMount() {
        const { value } = this.props
        this.setState({ ...this.state, value })
    }

    static getDerivedStateFromProps(nextProps: Props, prevState: State) {
        const { value } = nextProps
        if (value !== prevState.externalValue) {
            return { value, externalValue: value }
        }
        return null
    }

    onMove = (event: Point) => {
        const { width, onValueChange } = this.props
        const centerX = event.x + Slider.knobSize / 2
        const value = Math.min(Math.max(0, (centerX / width) * 100), 100)
        this.setState({ ...this.state, value })
        if (onValueChange) {
            onValueChange(value)
        }
    }

    render() {
        const { knob, track, tint, width, height } = this.props
        const value = Math.min(Math.max(this.state.value, 0), 100)
        const ratio = value / 100
        const left = Math.round(width * ratio - Slider.knobSize / 2)

        const constraints = {
            x: -Slider.knobSize / 2,
            y: height / 2 - Slider.knobSize / 2,
            width: width + Slider.knobSize,
            height: Slider.knobSize,
        }

        return (
            <>
                <Frame
                    left={0}
                    overflow={"hidden"}
                    height={2}
                    width={width}
                    top={height / 2 - 1}
                    background={track}
                    style={{ borderRadius: 50 }}
                >
                    <Frame width={`${ratio * 100}%`} top={0} left={0} bottom={0} background={tint} />
                </Frame>
                <Draggable
                    width={Slider.knobSize}
                    height={Slider.knobSize}
                    constraints={constraints}
                    bounce={false}
                    overdrag={false}
                    onMove={this.onMove}
                    horizontal={true}
                    vertical={false}
                    left={left}
                    top={height / 2 - Slider.knobSize / 2}
                    background={knob}
                    radius={Slider.knobSize}
                    shadows={[
                        {
                            inset: false,
                            color: "rgba(0,0,0,0.1)",
                            x: 0,
                            y: 0,
                            blur: 0,
                            spread: 1,
                        },
                        {
                            inset: false,
                            color: "rgba(0,0,0,0.05)",
                            x: 0,
                            y: 3,
                            blur: 1,
                            spread: 0,
                        },
                        {
                            inset: false,
                            color: "rgba(0,0,0,0.1)",
                            x: 0,
                            y: 2,
                            blur: 2,
                            spread: 0,
                        },
                        {
                            inset: false,
                            color: "rgba(0,0,0,0.05)",
                            x: 0,
                            y: 3,
                            blur: 3,
                            spread: 0,
                        },
                    ]}
                />
            </>
        )
    }
}
